import XCTest
@testable import CallDixio

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

private let validJSON = """
{
  "Status": "ok",
  "Wordbase": "swe_spa",
  "Result": [
    {
      "Value": "katt",
      "Type": "word",
      "VariantID": "1",
      "BaseLang": { "Meaning": "cat" },
      "TargetLang": { "Translation": "gato" }
    }
  ]
}
""".data(using: .utf8)!

private let emptyJSON = """
{ "Status": "ok", "Wordbase": "swe_spa", "Result": [] }
""".data(using: .utf8)!

private func makeResponse(statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

// MARK: - Tests

final class CallDixioTests: XCTestCase {

    @MainActor
    func testFetchPostsReturnsResults() async throws {
        MockURLProtocol.requestHandler = { _ in (makeResponse(), validJSON) }
        let viewModel = WordViewModel(session: makeMockSession())

        await viewModel.fetchPosts(word: "katt", dir: "to")

        XCTAssertGreaterThan(viewModel.results.count, 0)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testFetchPostsEmptyResultSetsNoMatch() async throws {
        MockURLProtocol.requestHandler = { _ in (makeResponse(), emptyJSON) }
        let viewModel = WordViewModel(session: makeMockSession())

        await viewModel.fetchPosts(word: "xyzxyz", dir: "to")

        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.error, .noMatch)
    }

    @MainActor
    func testFetchPostsInvalidResponseSetsError() async throws {
        MockURLProtocol.requestHandler = { _ in (makeResponse(statusCode: 500), Data()) }
        let viewModel = WordViewModel(session: makeMockSession())

        await viewModel.fetchPosts(word: "katt", dir: "to")

        XCTAssertEqual(viewModel.error, .invalidResponse)
    }

    @MainActor
    func testFetchPostsMalformedJSONSetsNoMatch() async throws {
        MockURLProtocol.requestHandler = { _ in (makeResponse(), Data("not json".utf8)) }
        let viewModel = WordViewModel(session: makeMockSession())

        await viewModel.fetchPosts(word: "katt", dir: "to")

        XCTAssertEqual(viewModel.error, .noMatch)
    }
}

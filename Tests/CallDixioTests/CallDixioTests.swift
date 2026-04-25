import XCTest
@testable import CallDixio

final class CallDixioTests: XCTestCase {

    @MainActor
    func testFetchPostsReturnsResults() async throws {
        let viewModel = WordViewModel()
        await viewModel.fetchPosts(word: "katt", dir: "to")
        XCTAssertGreaterThan(viewModel.results.count, 0)
        XCTAssertEqual(viewModel.errorMessage, "OK")
    }

    @MainActor
    func testFetchPostsInvalidWord() async throws {
        let viewModel = WordViewModel()
        await viewModel.fetchPosts(word: "xyzxyzxyz123", dir: "to")
        XCTAssertEqual(viewModel.errorMessage, "No word match")
    }
}

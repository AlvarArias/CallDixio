import XCTest
import Combine
@testable import CallDixio

final class CallDixioTests: XCTestCase {
    func testExample() throws {
     
        var viewModel: WordViewModel!
        var cancellables: Set<AnyCancellable> = []

        func setUp() {
            super.setUp()
            viewModel = WordViewModel()
        }

        func tearDown() {
            cancellables.removeAll()
            super.tearDown()
        }

        func testFetchPosts() {
            let expectation = XCTestExpectation(description: "Fetching posts from API")
            let word = "katt"
            let dir = "to"
            let url = URL(string: "http://lexin.nada.kth.se/lexin/service?searchinfo=\(dir),swe_spa,\(word)&output=JSON")!

            viewModel.$results
                .dropFirst()
                .sink(receiveValue: { results in
                    // Assert that at least one result was returned
                    XCTAssertGreaterThan(results.count, 0)
                    expectation.fulfill()
                })
                .store(in: &cancellables)

            viewModel.fetchPosts(word: word, dir: dir)

            wait(for: [expectation], timeout: 5.0)
        }
        
        
    }
    
    
    
}

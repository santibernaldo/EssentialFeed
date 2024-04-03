//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    /*
     ### Load Feed From Cache Use Case

     #### Primary course:
     1. Execute "Load Image Feed" command with above data.
     2. System fetches feed data from cache.
     3. System validates cache is less than seven days old.
     4. System creates image feed from cached data.
     5. System delivers image feed.

     #### Error course (sad path):
     1. System delivers error.

     #### Expired cache course (sad path):
     1. System deletes cache.
     2. System delivers no image feed.

     #### Empty cache course (sad path):
     1. System delivers no image feed.


     */

    /*
     DRY is a good principle, but not every code that looks alike is duplicate. Before deleting duplication, investigate if it's just an accidental duplication: code that seems the same but conceptually represents something else
     
     Mixing differenc concepts makes it harder to reason about separate parts of the system in isolacion, increasing its complexity
     
     This test may look "duplicate", but it's an "accidental duplication"
     
     Although we decided to keep the "Save" and "Load" methods in the samy type, they belong to different contexts/Use Cases
     
     By creating separate tests, if we ever decide to break those actions in separate types, it's much easier to do so The tests are already separated and with all the necessary assertions
     
     But in the future it can breaks into two types, so we don't want to make this happen.
     */
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
     }
    
    // First sad path
    func test_load_failsOnRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWithResults: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_delivesNoImagesOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWithResults: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResults expectedResult: LocalFeedLoader.LoadResult?, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for save completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected result, got \(receivedResult) instead")
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath,
                         line: UInt = #line) -> (store: FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}

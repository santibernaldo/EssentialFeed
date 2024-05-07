//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

import XCTest
import EssentialFeed

// Loading from the cache is a Query, and ideally should have no side-effects.
// Deleting the cache alters the state of the system, which is a side-effect
// The test name doesn't have to match the class name. This test class is testing the UseCase scenario, as is testing a bunch of classes colaborating between them.
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
    /*
     #### Error course (sad path):
     1. System delivers error.
     */
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
    
    //3. System validates cache is less than seven days old.
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        // 7 * 24 * 60 * 60 would be naive because it's not safe use days calculations because depending on daylight savings and calendar rules not every day has 24 hours
        
        // Every time the production code asks for a currentDate, it returns the same fixed date
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWithResults: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWithResults: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWithResults: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    // We complete the triangulation, minus 1 second, plus 1 second and equal to cache expiration
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })

        sut.load { _ in }
        
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_load_hasNoSideEffectsOnExpirationCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })

        sut.load { _ in }
        
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })

        sut.load { _ in }
        
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
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
}


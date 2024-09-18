//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/4/24.
//

import XCTest
import EssentialFeed

/*
 ### Validates Feed From Cache Use Case

 #### Primary course:
 1. Execute "Validate Cache" command with above data.
 2. System retrieves feed data from cache.
 3. System validates cache is less than seven days old.

 #### Retrieval error course (sad path):
 1. System deletes cache.

 #### Expired cache course (sad path):
 1. System deletes cache.

 #### Empty cache course (sad path):
 1. System delivers no image feed.

 */

// A Command changes the state of a system (side-effects) but does not return a value.
final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        store.completeRetrieval(with: anyNSError())
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        store.completeRetrievalWithEmptyCache()
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_validateCache_doesNotDeleteOnNonExpiredTimestamp() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache])
    }
    
    func test_validateCache_deletesCacheOnSevenDaysOldCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache, .deleteCacheFeed])
    }
    
    func test_validatesCache_deletesCacheOnMoreThanSevenDaysOldCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        // CODE: fixedCurrendDate
        let (store, sut) = makeSUT (currentDate: { fixedCurrentDate })
        
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieveCache, .deleteCacheFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccesfully()
        })
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = makeUniqueFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletionSuccesfully()
        })
    }
    
    //MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        let receivedResult = Result { try sut.validateCache() }
        
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func makeUniqueFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localFeed = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (feed, localFeed)
    }
}


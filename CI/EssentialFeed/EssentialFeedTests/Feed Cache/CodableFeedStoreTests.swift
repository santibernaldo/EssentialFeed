//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/4/24.
//

/*
 FeedStore implementation Inbox

 - Retrieve
     - Empty cache twice returns empty (no side-effects)
     - Empty cache works (before something is inserted)
     - Non-empty cache returns data
     - Non-empty cache twice returns same data (retrieve should have no side-effects)
     - Error returns error (if applicable, e.g., invalid data)
     - Error twice returns same error (if applicable, e.g., invalid data)

 - Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)
 */

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    // Empty cache works (before something is inserted)
    // With this test, we be sure we don't leave artifacts, side-effects, (items saved on cache)
    // So we use the tearDown to remove any data we can be saving
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
                
        expect(sut, toRetrieve: .emptyCache)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // Given
        let sut = makeSUT()
        
        let feed = makeUniqueFeed().local
        let timestamp = Date()
        
        // When
        insert(sut, feed: feed, timestamp: timestamp)
        
        // Then
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
                
        expect(sut, toRetrieve: .emptyCache)
        expect(sut, toRetrieve: .emptyCache)
    }
    
    // We insert, then we retrieve twice and we check that we get the same result back
    // - Non-empty cache twice returns same data (retrieve should have no side-effects)

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        let feed = makeUniqueFeed().local
        let timestamp = Date()
        
        insert(sut, feed: feed, timestamp: timestamp)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    //      - Error returns error (if applicable, e.g., invalid data)
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testsSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failureCache(anyNSError()))
    }
    
    // - Error twice returns same error (if applicable, e.g., invalid data)
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testsSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failureCache(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert(sut, feed: makeUniqueFeed().local, timestamp: Date())
        XCTAssertNil(firstInsertionError, "Expected success, but got an error")
        
        let latestFeed = makeUniqueFeed().local
        let latestTimestamp = Date()
        
        let lastInsertionError = insert(sut, feed: latestFeed, timestamp: latestTimestamp)
        XCTAssertNil(lastInsertionError, "Expected success but found last insertion error")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let insertionError = insert(sut, feed: makeUniqueFeed().local, timestamp: Date())
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .emptyCache)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(sut, feed: makeUniqueFeed().local, timestamp: Date())
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .emptyCache)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .emptyCache)
    }
    
    // - MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testsSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

    private func testsSpecificStoreURL() -> URL {
        // type(of: self) will return ´CodableFeedStoreTests
        // .cachesDirectory for the tests, instead of .documents
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testsSpecificStoreURL())
    }
    
   @discardableResult
    private func insert(_ sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "Wait for cache retrieval")

        var insertionError: Error?
        sut.insert(feed, timestamp: timestamp) { insertedError in
            insertionError = insertedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCacheFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case let (.emptyCache, .emptyCache), let (.failureCache, .failureCache):
                
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        wait(for: [exp], timeout: 1.0)
    }
}

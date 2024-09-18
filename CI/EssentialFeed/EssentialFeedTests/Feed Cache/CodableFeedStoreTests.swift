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


final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    // Sometimes the tearDown method cannot be called, in case our system failed, or it didn't end the test because a breakpoint was stopped, without calling the completion and the test didn't end, so we need to to remove the artifacts on the setUp method
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    // Empty cache works (before something is inserted)
    // With this test, we be sure we don't leave artifacts, side-effects, (items saved on cache)
    // So we use the tearDown to remove any data we can be saving
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
                
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // Given
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
                
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    // We insert, then we retrieve twice and we check that we get the same result back
    // - Non-empty cache twice returns same data (retrieve should have no side-effects)

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    //      - Error returns error (if applicable, e.g., invalid data)
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testsSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
                
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    // - Error twice returns same error (if applicable, e.g., invalid data)
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testsSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
//    // Orders matters, so that's what we measure here. The order of being executed these operations, one after another
//    func test_storeSideEffects_runSerially() {
//        let sut = makeSUT()
//        
//        assertThatSideEffectsRunSerially(on: sut)
//    }
                                       
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
    
    //The cache directory permission is different in the iOS simulator (you can delete the directory on the simulator, but not on the macOS target!). So, as Shawn described above, you need to use the .systemDomainMask only for the 'deletion error' tests. For example:
    
    //Just in case anyone else runs into the same issue I had when running the CodableFeedStoreTests on iOS, it was due to the fact that when running the tests on the simulator, we do in fact have permission to delete the caches directory from the filesystem. To fix, change how you get the supposed directory without deletion permission to use the systemDomainMask instead:
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testsSpecificStoreURL())
    }
    
    
}

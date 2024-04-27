//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/4/24.
//

import XCTest
import EssentialFeed

// We check here how the system behaves with real instances of the production code

// The system under test in integration with the CoreDataFeedStore integration
final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    // Sometimes the tearDown method cannot be called, in case our system failed, or it didn't end the test because a breakpoint was stopped, without calling the completion and the test didn't end, so we need to to remove the artifacts on the setUp method
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_delivers_NoItemsOnEmptyCache() {
        let sut = makeFeedLoader()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = makeUniqueFeed().models
        
        expect(feedLoaderToPerformSave, toSave: feed)

        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnSeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = makeUniqueFeed().models
        let latestFeed = makeUniqueFeed().models
        
        expect(feedLoaderToPerformSave, toSave: firstFeed)
        expect(feedLoaderToPerformLastSave, toSave: latestFeed)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - Helpers
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testsSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected succesful feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toSave expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for load completion")
        
        sut.save(expectedFeed) { saveError in
            XCTAssertNil(saveError as? Error, "Expected to save feed succesfully", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private func testsSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

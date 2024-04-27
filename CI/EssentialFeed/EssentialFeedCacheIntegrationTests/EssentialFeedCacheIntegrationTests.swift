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
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
                
            case let .failure(error):
                XCTFail("Expected succesful feed result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = makeUniqueFeed().models
        
        let saveExp = expectation(description: "Wait for save completion")
        feedLoaderToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError as? Error, "Expected to save feed successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 2.0)
        
        let loadExp = expectation(description: "Wait for load completion")
        feedLoaderToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, feed)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
    
    
    // MARK: - Helpers
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testsSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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

//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 27/3/24.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCacheFeed() {
        deleteCachedFeedCallCount = 1
    }
}

class LocalFeedLoader {
    
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed()
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    /*
     #### Primary course (happy path):
     1. Execute "Save Feed Items" command with above data.
     2. System deletes old cache data.
     3. System encodes feed items.
     4. System timestamps the new cache.
     5. System saves new cache data.
     6. System delivers success message.

     */
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_doesDeleteCacheUponCreation() {
        let (store, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (store: FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
}

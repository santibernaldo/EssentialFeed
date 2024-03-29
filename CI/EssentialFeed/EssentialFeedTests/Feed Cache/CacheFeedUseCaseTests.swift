//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 27/3/24.
//

import XCTest
import EssentialFeed


class LocalFeedLoader {
    
    private let currentDate: () -> Date
    private let store: FeedStore
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletions = [DeletionCompletion]()
    
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccesfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items, timestamp))
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
     
     #### Deleting error course (sad path):
     1. System delivers error.

     #### Saving error course (sad path):
     1. System delivers error.

     */
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    // 1. Recipe step
    func test_save_doesDeleteCacheUponCreation() {
        let (store, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // 2. Recipe step
    // We protect with this test avoid calling the error method on the wrong time
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (store, sut) = makeSUT()
        let deletionError = anyError()
        
        sut.save(items)
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccesfulDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (store, sut) = makeSUT()
        
        sut.save(items)
        store.completeDeletionSuccesfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // 4. System timestamps the new cache.
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccesfulDeletion() {
        let timestamp = Date()
        
        let items = [uniqueItem(), uniqueItem()]
        // The current date/time is not a pure function (every time you create a Date instance, it has a different value-the current date/time)

        // Instead of letting the Use Case produce the current date via the impure Date.init() function directly, we can move this responsibility to a collaborator (a simple closure in this case) and inject it as a dependency. Then, we can easily control the current date/time during tests.
        let (store, sut) = makeSUT {
            timestamp
        }
        
        sut.save(items)
        store.completeDeletionSuccesfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    
    //MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath,
                         line: UInt = #line) -> (store: FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
}

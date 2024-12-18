//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 27/3/24.
//

import XCTest
import EssentialFeed

class SaveCacheFeedUseCaseTests: XCTestCase {
    
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
    
//    func test_init_doesNotDeleteCacheUponCreation() {
//        let (store, _) = makeSUT()
//        
//        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
//    }
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // 1. Recipe step
    func test_save_doesDeleteCacheUponCreation() {
        let (store, sut) = makeSUT()
        
        sut.save(makeUniqueFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    // 2. Recipe step
    // We protect with this test avoid calling the error method on the wrong time
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(makeUniqueFeed().models) { _ in }
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    // 4. System timestamps the new cache.
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccesfulDeletion() {
        let timestamp = Date()
        
        let (feed, localFeed) = makeUniqueFeed()
        // The current date/time is not a pure function (every time you create a Date instance, it has a different value-the current date/time)

        // Instead of letting the Use Case produce the current date via the impure Date.init() function directly, we can move this responsibility to a collaborator (a simple closure in this case) and inject it as a dependency. Then, we can easily control the current date/time during tests.
        let (store, sut) = makeSUT {
            timestamp
        }
        
        sut.save(feed) { _ in }
        store.completeDeletionSuccesfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localFeed, timestamp)])
    }
    
    /*
     #### Deleting error course (sad path):
     1. System delivers error.
     */
    func test_save_failsOnDeletionError() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: .failure(deletionError)) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    /*
     #### Saving error course (sad path):
     1. System delivers error.
     */
    func test_save_failsOnInsertionError() {
        let (store, sut) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: .failure(insertionError)) {
            store.completeDeletionSuccesfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSavingCache() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccesfully()
            store.completeInsertionSuccesfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var capturedResults = [LocalFeedLoader.SaveResult?]()
        sut?.save([uniqueImage()]) { capturedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var capturedResults = [LocalFeedLoader.SaveResult?]()
        sut?.save([uniqueImage()]) { capturedResults.append($0) }
        
        store.completeDeletionSuccesfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    //MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath,
                         line: UInt = #line) -> (store: FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: LocalFeedLoader.SaveResult?, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion")
        
        var receivedError: LocalFeedLoader.SaveResult?
        sut.save([uniqueImage(), uniqueImage()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError as? NSError)
    }
    
    
}

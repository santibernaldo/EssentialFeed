//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/4/24.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
         let exp = expectation(description: "Wait for cache retrieval")

         var insertionError: Error?
         sut.insert(feed, timestamp: timestamp) { insertedError in
             insertionError = insertedError
             exp.fulfill()
         }
         
         wait(for: [exp], timeout: 1.0)
         return insertionError
     }
     
     @discardableResult
     func deleteCache(from sut: FeedStore) -> Error? {
         let exp = expectation(description: "Wait for cache deletion")
         var deletionError: Error?
         sut.deleteCacheFeed { receivedDeletionError in
             deletionError = receivedDeletionError
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
         return deletionError
     }
}

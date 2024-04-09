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

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.emptyCache)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    // Empty cache works (before something is inserted)
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .emptyCache:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

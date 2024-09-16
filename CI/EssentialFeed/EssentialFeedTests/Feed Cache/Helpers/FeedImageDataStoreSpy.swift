//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/7/24.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    public enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    // STAR: Capturing receivedMessages, its still a SPY
    private(set) var receivedMessages = [Message]()
    // STAR: But we stub the results
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    // STAR: We STUB the result before invoking the method. The order of the behaviour changed, after moving to a SYNC API
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    // STAR: We STUB the result before invoking the method
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}

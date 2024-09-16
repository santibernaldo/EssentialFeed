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
    
    private(set) var receivedMessages = [Message]()
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionResult: Result<Void, Error>?

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
      
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
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

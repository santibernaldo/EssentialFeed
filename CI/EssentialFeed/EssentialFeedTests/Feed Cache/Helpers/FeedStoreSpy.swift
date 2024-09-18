//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//
import EssentialFeed

class FeedStoreSpy {
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieveCache
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?
        
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccesfully(at index: Int = 0) {
        deletionResult = .success(())
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccesfully(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date,  at index: Int = 0) {
        retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
    }
}

extension FeedStoreSpy: FeedStore {
    func retrieve() throws -> CachedFeed? {
        receivedMessages.append(.retrieveCache)
        return try retrievalResult?.get()
    }
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCacheFeed)
        try deletionResult?.get()
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(feed, timestamp))
        try insertionResult?.get()
    }
}

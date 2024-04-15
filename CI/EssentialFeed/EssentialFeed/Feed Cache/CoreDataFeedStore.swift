//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/4/24.
//

public final class CoreDataFeedStore: FeedStore {
  
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.emptyCache)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}

//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 11/7/24.
//


import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            }
        }
        // WAS THIS PREVIOUS CODE
        //            do {
        //                if let cache = try ManagedCache.find(in: context) {
        //                    completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
        //                } else {
        //                    completion(.success(.none))
        //                }
        //            } catch {
        //                completion(.failure(error))
        //            }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                do {
                    let managedCache = try ManagedCache.newUniqueInstance(in: context)
                    managedCache.timestamp = timestamp
                    managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                    try context.save()
                } catch {
                    // STAR: when there's a failure, we need to revert the changes
                    context.rollback()
                }
            }
        }
    }
    
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                do {
                    try ManagedCache.deleteCache(in: context)
                } catch {
                    // We do a rollback on the context every time the deleteError throws
                    context.rollback()
                }
            }
        }
    }
}

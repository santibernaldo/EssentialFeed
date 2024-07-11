//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 11/7/24.
//

}
import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            // An optional can be mapped as a .some or .none value if none is found
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
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
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                // when there's a failure, we need to revert the changes
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                // We try to find the cache, if found we delete it, and then we save the operation
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(.success(()))
            } catch {
                // We do a rollback on the context every time the deleteError throws
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
}

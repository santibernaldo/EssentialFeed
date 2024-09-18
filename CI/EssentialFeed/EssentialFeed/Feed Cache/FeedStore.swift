//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

// Independent from Framework details. We can use Realm, CoreData or wharever persistence framework we want.

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
    
//    // STAR:
//    /// The client is the responsible to use the right thread type, Main Queue to use this data on a main thread, or on a background thread
//    
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropiate thread, if needed
//    @available(*, deprecated)
//    func deleteCachedFeed(completion: @escaping DeletionCompletion)
//    
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropiate thread, if needed
//    @available(*, deprecated)
//    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
//    
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropiate thread, if needed
//    @available(*, deprecated)
//    func retrieve(completion: @escaping RetrievalCompletion)
}

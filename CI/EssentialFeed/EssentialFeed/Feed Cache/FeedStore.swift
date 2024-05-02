//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

// Independent from Framework details. We can use Realm, CoreData or wharever persistence framework we want.

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias Result = Swift.Result<CachedFeed, Error>
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Result?) -> Void

    /// The client is the responsible to use the right thread type, Main Queue to use this data on a main thread, or on a background thread
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropiate thread, if needed
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropiate thread, if needed
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropiate thread, if needed
    func retrieve(completion: @escaping RetrievalCompletion)
}


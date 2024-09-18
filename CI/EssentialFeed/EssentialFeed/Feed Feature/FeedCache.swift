//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/8/24.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    // STAR: On this SERVICE LAYER, we got a completion asynchronous block, because we depend on the INFRASTRUCTURE details
    // The infrastructure implementation needs to be asynchronous because we don't want to block the main thread
    // We are leaking Infrastructure details into the Domain layer, but that's common its not a big problem, but its a Leaky abstraction
    // STAR: A solution to not be leaking infrastructure details every where (THE ASYNC) is to make the INFRASTRUCTURE synchronous
    func save(_ feed: [FeedImage]) throws
}

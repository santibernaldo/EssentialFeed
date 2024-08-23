//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/8/24.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

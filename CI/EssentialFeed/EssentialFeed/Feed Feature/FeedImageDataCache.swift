//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/8/24.
//

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}

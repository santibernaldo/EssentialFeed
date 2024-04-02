//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

import Foundation

public typealias LoadFeedResult = Swift.Result<[FeedImage], Error>

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}

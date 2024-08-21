//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

/*
 
 Domain Services dependencies and Domain Models
 
 */

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> ())
}

//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

import Foundation

protocol FeedItemLoader {
    func getFeedResult() async -> Result<FeedItem, Error>
}

//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/9/24.
//

import Foundation

// STAR: Representation of a Page (with items)
// STAR: UI doesn`t need to know when update or not
// STAR: It holds the feed, but we need more info about the state of paginating
public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
    
    public let items: [Item]
    // Action of loadMore items
    // STAR: If I don't have a closure, I can`t load more. That's the Optional part
    let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
           self.items = items
           self.loadMore = loadMore
       }
}

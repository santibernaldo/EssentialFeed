//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

import Foundation

// This one doesn't know about the API, it's like the Domain object
public struct FeedItem: Equatable {
    public let id: UUID
    public var description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

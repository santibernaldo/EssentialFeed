//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

import Foundation

// This one doesn't know about the API, it's like the Domain object
public struct FeedImage: Equatable {
    public let id: UUID
    public var description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

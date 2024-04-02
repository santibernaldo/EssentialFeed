//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

// Internal representation of the FeedItem for the API Module
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal var description: String?
    internal let location: String?
    internal let image: URL
}

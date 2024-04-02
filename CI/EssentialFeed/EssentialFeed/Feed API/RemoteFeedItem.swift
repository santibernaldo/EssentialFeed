//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

// We keep here the 'Item', so its an internal representation from the Backend, as they call it, the items. From the Domain, the name is more an Image, but this can changes in the future. The Backend can return ads, videos, posts..

// Internal representation of the FeedItem for the API Module
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal var description: String?
    internal let location: String?
    internal let image: URL
}

//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

// We keep here the 'Item', so its an  representation from the Backend, as they call it, the items. From the Domain, the name is more an Image, but this can changes in the future. The Backend can return ads, videos, posts..

//  representation of the FeedItem for the API Module
 struct RemoteFeedItem: Decodable {
     let id: UUID
     var description: String?
     let location: String?
     let image: URL
}

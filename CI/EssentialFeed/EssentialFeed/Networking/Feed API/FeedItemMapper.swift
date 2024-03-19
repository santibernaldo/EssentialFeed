//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 27/2/24.
//

internal final class FeedItemMapper {
    private struct RootFeedItem: Decodable {
        let items: [Item]
    }

    // Internal representation of the FeedItem for the API Module
    private struct Item: Decodable {
        let id: UUID
        var description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image)
        }
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(RootFeedItem.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        let items = root.items.map { $0.item }
        return .success(items)
    }
}

//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 24/8/24.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}

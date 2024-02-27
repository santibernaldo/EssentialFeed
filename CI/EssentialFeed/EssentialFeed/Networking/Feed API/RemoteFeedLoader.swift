//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 29/12/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    
    public typealias Result = Swift.Result<[FeedItem], Error>
    
    private let client: HTTPClient
    
    // The URL is a detail of the implementation of the RemoteFeedLoader
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void ) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, _):
                if let root = try? JSONDecoder().decode(RootFeedItem.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct RootFeedItem: Decodable {
    let items: [FeedItem]
}



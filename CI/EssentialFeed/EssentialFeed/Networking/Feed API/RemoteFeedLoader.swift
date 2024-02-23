//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 29/12/23.
//

import Foundation

public protocol HTTPClient {
    func load(url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    
    // The URL is a detail of the implementation of the RemoteFeedLoader
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.load(url: url) { error in
            completion(.connectivity)
        }
    }
}




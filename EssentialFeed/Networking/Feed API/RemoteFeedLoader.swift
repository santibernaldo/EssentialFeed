//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 29/12/23.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.load(url: url)
    }
}

public protocol HTTPClient {
    func load(url: URL)
}


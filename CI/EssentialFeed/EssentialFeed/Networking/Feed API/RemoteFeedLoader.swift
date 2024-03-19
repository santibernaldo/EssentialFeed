//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 29/12/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public typealias Result = LoadFeedResult
    
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
    
    public func load(completion: @escaping (LoadFeedResult) -> ()){
        client.get(url: url) { [weak self] result in
            
            // With the static FeedMapper.map into the completion, we avoid a memory leak
            // And unwrapping the self, we avoiding calling the completion in case RemoteFeedLoader
            // have been deallocated. Sometimes UIViewControllers have been deallocated, but some
            // labels or other properties are called through a completionBlock after 
            guard self != nil else { return }
            
            switch result {
            case .success(let data, let response):
                completion(FeedItemMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}






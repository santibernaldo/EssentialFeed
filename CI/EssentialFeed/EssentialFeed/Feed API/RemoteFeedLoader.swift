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
            
            //Without this self, we can create a retain cycle. We don't know the implementation of the client, maybe it's a Singleton
            
            // We can check without this self != nil the instance is deallocated but we call the completion: test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated
            
            switch result {
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}





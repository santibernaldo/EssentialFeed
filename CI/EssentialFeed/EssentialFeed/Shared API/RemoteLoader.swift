//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 24/8/24.
//

import Foundation
//
//public final class RemoteLoader<Resource> {
//    // The URL is a detail of the implementation of the RemoteFeedLoader
//    private let url: URL
//    private let client: HTTPClient
//    private let mapper: Mapper
//    
//    public enum Error: Swift.Error {
//        case connectivity
//        case invalidData
//    }
//    
//    public typealias Result = Swift.Result<Resource, Swift.Error>
//    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
//
//    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
//        self.url = url
//        self.client = client
//        self.mapper = mapper
//    }
//    
//    public func load(completion: @escaping (Result) -> Void) {
//        client.get(from: url) { [weak self] result in
//            
//            // With the static FeedMapper.map into the completion, we avoid a memory leak
//            // And unwrapping the self, we avoiding calling the completion in case RemoteFeedLoader
//            // have been deallocated. Sometimes UIViewControllers have been deallocated, but some
//            // labels or other properties are called through a completionBlock after
//            guard let self = self else { return }
//                        
//            //Without this self, we can create a retain cycle. We don't know the implementation of the client, maybe it's a Singleton
//            
//            // We can check without this self != nil the instance is deallocated but we call the completion: test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated
//            switch result {
//            case let .success((data, response)):
//                completion(self.map(data, from: response))
//                
//            case .failure:
//                completion(.failure(Error.connectivity))
//            }
//        }
//    }
//    
//    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
//        do {
//            return .success(try mapper(data, response))
//        } catch {
//            return .failure(Error.invalidData)
//        }
//    }
//}

//
//  FeedLoaderCacheDecorator.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/8/24.
//

//import EssentialFeed
//import Combine
//
//// We don`t need tests to test this behaviour, because it's a Combine built-in operator, for injecting side-effects
//extension Publisher where Output == [FeedImage] {
//    // Returns the same tipe and Failure
//    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
//        // ´handleEvents´an special operator, to inject side-effects. You don't need to return anything, because you're not supposed to transform this value
//        
//        // As saveIgnoringResult has the same signature as the Output, we can pass it directly in one liner
//        handleEvents(receiveOutput: cache.saveIgnoringResult)
//        .eraseToAnyPublisher()
//    }
//}

/*
 Not every client of the FeedLoader protocol needs the save method (Interface Segregation Principle).
 
 That's why we use the Decorator pattern
// */
//public final class FeedLoaderCacheDecorator: FeedLoader {
//    private let decoratee: FeedLoader
//    // FeedCache is an abstraction of the FeedCache saving, which is implemented by the LocalFeedLoader. We could pass here the LocalFeedLoader, but it can break our tests because of one of their dependencies. So we abstract the only thing we need, which is saving.
//    private let cache: FeedCache
//    
//    public init(decoratee: FeedLoader, cache: FeedCache) {
//        self.decoratee = decoratee
//        self.cache = cache
//    }
//    
//    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        decoratee.load { [weak self] result in
//            if let feed = try? result.get() {
//                self?.cache.saveIgnoringResult(feed)
//            }
//            completion(result)
//            // WAY OF REMOVING IFS
//            /*
//             decoratee.load { [weak self] result in
//                 completion(result.map { feed in
//                    self?.cache.saveIgnoringResult(feed)
//                    return feed
//                })
//            })
//             */
//        }
//    }
//}



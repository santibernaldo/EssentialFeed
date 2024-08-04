//
//  FeedLoaderCacheDecorator.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/8/24.
//

/*
 Not every client of the FeedLoader protocol needs the save method (Interface Segregation Principle).
 
 That's why we use the Decorator pattern
 */
public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.saveIgnoringResult(feed)
            }
            completion(result)
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

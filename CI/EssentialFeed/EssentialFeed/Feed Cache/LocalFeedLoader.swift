//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

// Centralized component for dealing with the Cache.

// It interacts with UseCases, like FeedStore, so it can be a Controller, Interactor, Model Controller... It holds application specific business logic

//MARK: - Application Specific Business Logic, not Business Rules 
public final class LocalFeedLoader {
   
    private let store: FeedStore
    private let currentDate: () -> Date
        
    public enum ErrorLocalFeedLoader: Swift.Error {
        case invalidData
    }
    
    // To decouple the application from Framework details, we don't let frameworks dictate the Use Case interfaces (adding Codable requirements or CoreData managed context parameters) we only pass a FeedStore class
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>

    public func load(completion: @escaping (LoadResult) -> ()) {
        completion(LoadResult {
            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                return cache.feed.toModels()
            }
            return []
        })
    }
}

// STAR: Performance improvements on our SERVICES CLASSES, like this. We would pollute the class. This kind of improvements are better done on the INFRASTRUCTURE side.
extension LocalFeedLoader: FeedCache {
    
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        completion(ValidationResult {
            do {
                if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    throw InvalidCache()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

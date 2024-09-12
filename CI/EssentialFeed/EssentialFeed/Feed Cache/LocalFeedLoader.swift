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
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cachedFeed)) where FeedCachePolicy.validate(cachedFeed.timestamp, against: currentDate()):
                completion(.success(cachedFeed.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

// STAR: Performance improvements on our SERVICES CLASSES, like this. We would pollute the class. This kind of improvements are better done on the INFRASTRUCTURE side.
extension LocalFeedLoader: FeedCache {

    public typealias SaveResult = FeedCache.Result

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> ()) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> ()) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            switch insertionResult {
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.success(()))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
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

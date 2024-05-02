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

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> ()) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            if let result = result {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: currentDate()):
                    completion(.success(feed.toModels()))
                case .found:
                    completion(.success([]))
                case .empty:
                    completion(.success([]))
                }
            }
        }
    }
}

extension LocalFeedLoader {

    public typealias SaveResult = Error?

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult?) -> ()) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult?) -> ()) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            if let result = result {
                switch result {
                case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: currentDate()):
                    store.deleteCachedFeed(completion: { _ in })
                    
                case .failure:
                    store.deleteCachedFeed(completion: { _ in })
                    
                case .found, .empty:
                    break
                }
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

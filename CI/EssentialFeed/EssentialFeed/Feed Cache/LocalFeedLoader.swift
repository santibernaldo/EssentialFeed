//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

// Policy/Rules business model separated from the UseCase ´LocalFeedLoader´which is acting as an Interactor/Controller (Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles from Modulo 2)
private final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = FeedCachePolicy.calendar.date(byAdding: .day, value: FeedCachePolicy.maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

// Centralized component for dealing with the Cache.
public final class LocalFeedLoader {
   
    private let store: FeedStore
    private let currentDate: () -> Date
        
    public enum ErrorLocalFeedLoader: Swift.Error {
        case invalidData
    }
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> ()) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            if let result = result {
                switch result {
                case let .failureCache(error):
                    completion(.failure(error))
                case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: currentDate()):
                    completion(.success(feed.toModels()))
                case .found:
                    completion(.success([]))
                case .emptyCache:
                    completion(.success([]))
                }
            }
        }
    }
}

extension LocalFeedLoader {

    public typealias SaveResult = Error?

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult?) -> ()) {
        store.deleteCacheFeed { [weak self] error in
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
                    store.deleteCacheFeed(completion: { _ in })
                    
                case .failureCache:
                    store.deleteCacheFeed(completion: { _ in })
                    
                case .found, .emptyCache:
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

//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

public final class LocalFeedLoader {
    private let currentDate: () -> Date
    private let store: FeedStore
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public enum ErrorLocalFeedLoader: Swift.Error {
        case invalidData
    }
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadResult?) -> ()) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            if let result = result {
                switch result {
                case let .failureCache(error):
                    completion(.failure(error))
                case let .found(feed, timestamp) where self.validate(timestamp):
                    completion(.success(feed.toModels()))
                case .found, .emptyCache:
                    completion(.success([]))
                }
            }
        }
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
    
    func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult?) -> ()) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
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



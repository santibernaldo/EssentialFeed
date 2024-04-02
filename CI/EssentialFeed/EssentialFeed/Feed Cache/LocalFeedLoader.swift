//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/3/24.
//

public final class LocalFeedLoader {
    private let currentDate: () -> Date
    private let store: FeedStore
    
    public typealias SaveResult = Error?
    
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
    
    public func load(completion: @escaping (Error?) -> ()) {
        store.retrieve { error in
            if let retrievalError = error {
                completion(retrievalError)
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

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}



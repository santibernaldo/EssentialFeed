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
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult?) -> ()) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    func cache(_ items: [FeedItem], with completion: @escaping (SaveResult?) -> ()) {
        self.store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}



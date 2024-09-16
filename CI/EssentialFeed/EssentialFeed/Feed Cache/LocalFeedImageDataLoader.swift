//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/7/24.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL) throws {
        // CODE: Question SaveResult {}
//        let saveResult: SaveResult = SaveResult {
//            try store.insert(data, for: url)
//        }.mapError { _ in SaveError.failed }
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {

    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        
        throw LoadError.notFound
    }
}

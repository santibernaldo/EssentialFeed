//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 11/4/24.
//

import CoreData

// INFRASTRUCTURES, Components with side effects, pushing the boundaries of the system.
// Infrastructures components are messy deal with Network, Persistence... things that can fails, and has side-effects (insert or delete functions, not QUERY functions)
public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Equatable, Codable {
        public let id: UUID
        public var description: String?
        public let location: String?
        public let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    // With this queue we make sure that operations run SERIALLY in order
    // We add the .concurrent type to have some of the operations being running concurrently, like the 'retrieve' one, which is one which doesn't leave any side-effects on disk
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    // Implicit dependency that we avoid
    //private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encodedData = try encoder.encode(cache)
                try encodedData.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
        
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        let storeURL = self.storeURL
        // With the .barrier we make sure we don't create any Race Conditions when inserting, deleting stuff
        // These operations run Serially, we guarantee data consistency, so every insertion ends with it required to be finished, so other thread doesn't try to access a value that doesn't exist, or it's wrong (THEY ARE RUN BLOCKING THE EXECUTION BEFORE GETTING FINISHED)
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}


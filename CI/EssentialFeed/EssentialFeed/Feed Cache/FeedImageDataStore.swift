//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/7/24.
//

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
//
//// STAR: Temporary implementation, so we don't break clients
//public extension FeedImageDataStore {
//    func insert(_ data: Data, for url: URL) throws {
//        let group = DispatchGroup()
//        group.enter()
//        var result: InsertionResult!
//        insert(data, for: url) {
//            result = $0
//            group.leave()
//        }
//        group.wait()
//        return try result.get()
//    }
//
//    func retrieve(dataForURL url: URL) throws -> Data? {
//        let group = DispatchGroup()
//        group.enter()
//        var result: RetrievalResult!
//        retrieve(dataForURL: url) {
//            result = $0
//            group.leave()
//        }
//        group.wait()
//        return try result.get()
//    }
//    
//    // STAR: Empty Implementations, so as we MIGRATE, we don't need to implement them Anymore
//    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
//    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
//}


//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/4/24.
//

import XCTest

// We check here how the system behaves with real instances of the production code
final class EssentialFeedCacheIntegrationTests: XCTestCase {

    // MARK: - Helpers
//    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
//        let storeBundle = Bundle(for: CoreDataFeedStore.self)
//        // dev/null doesn't leave any artifacts
//        let storeURL = URL(fileURLWithPath: "/dev/null")
//        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
    
    private func testsSpecificStoreURL() -> URL {
        // type(of: self) will return ´CodableFeedStoreTests
        // .cachesDirectory for the tests, instead of .documents
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

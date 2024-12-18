//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/8/24.
//

// Instead of altering and complicating our current components, we can create a new composite to intercept the load operation and inject the save-side-effect

// In other words, we'll be intercepting FeedLoaders and adding a new behavior into it

// How?! By decorating FeedLoaders. With the Decorator pattern, modifying its behaviour

//import XCTest
//import EssentialFeed
//import EssentialApp
//
//class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
//
//    func test_load_deliversFeedOnLoaderSuccess() {
//        let feed = uniqueFeed()
//        let sut = makeSUT(loaderResult: .success(feed))
//
//        expect(sut, toCompleteWith: .success(feed))
//    }
//    
//    func test_load_deliversErrorOnLoaderFailure() {
//        let sut = makeSUT(loaderResult: .failure(anyNSError()))
//
//        expect(sut, toCompleteWith: .failure(anyNSError()))
//    }
//    
//    func test_load_cachesLoadedFeedOnLoaderSuccess() {
//        let cache = CacheSpy()
//        let feed = uniqueFeed()
//        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
//
//        sut.load { _ in }
//        
//        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
//    }
//    
//    func test_load_doesNotCacheOnLoaderFailure() {
//        let cache = CacheSpy()
//        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
//        
//        sut.load { _ in }
//        
//        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
//    }
//    
//    // MARK: - Helpers
//    
//    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
//        let loader = FeedLoaderStub(result: loaderResult)
//        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
//        trackForMemoryLeaks(loader, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//    
//    private class CacheSpy: FeedCache {
//        private(set) var messages = [Message]()
//        
//        enum Message: Equatable {
//            case save([FeedImage])
//        }
//        
//        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
//            messages.append(.save(feed))
//            completion(.success(()))
//        }
//    }
//    
//}

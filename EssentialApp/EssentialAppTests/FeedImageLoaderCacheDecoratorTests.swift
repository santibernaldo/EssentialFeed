//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/8/24.
//

import Foundation
import EssentialFeed
import XCTest

protocol FeedImageCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

final class FeedImageCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
   
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

class FeedImageLoaderCacheDecoratorTests: XCTestCase, FeedImageLoaderTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private class CacheSpy: FeedImageCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(Data)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data))
            completion(.success(()))
        }
    }
    
}


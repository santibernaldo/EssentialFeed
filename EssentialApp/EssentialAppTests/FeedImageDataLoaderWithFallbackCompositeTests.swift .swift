//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift .swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/7/24.
//
//import XCTest
//import EssentialFeed
//import EssentialApp
//
//class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageLoaderTestCase {
//    
//    func test_init_doesNotLoadImageData() {
//        let (_, primaryLoader, fallbackLoader) = makeSUT()
//
//        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
//        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
//    }
//    
//    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
//        let url = anyURL()
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//
//        _ = sut.loadImageData(from: url) { _ in }
//        
//        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
//        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
//    }
//    
//    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
//        let url = anyURL()
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//
//        _ = sut.loadImageData(from: url) { _ in }
//        
//        primaryLoader.complete(with: anyNSError())
//        
//        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
//        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
//    }
//    
//    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
//        let url = anyURL()
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//
//        let task = sut.loadImageData(from: url) { _ in }
//        task.cancel()
//        
//        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
//        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
//    }
//    
//    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
//        let url = anyURL()
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//
//        let task = sut.loadImageData(from: url) { _ in }
//        primaryLoader.complete(with: anyNSError())
//        task.cancel()
//        
//        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
//        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
//    }
//        
//    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
//        let primaryData = anyData()
//        let (sut, primaryLoader, _) = makeSUT()
//        
//        expect(sut, toCompleteWith: .success(primaryData), when: {
//            primaryLoader.complete(with: primaryData)
//        })
//    }
//    
//    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
//        let fallbackData = anyData()
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//        
//        expect(sut, toCompleteWith: .success(fallbackData), when: {
//            primaryLoader.complete(with: anyNSError())
//            fallbackLoader.complete(with: fallbackData)
//        })
//    }
//    
//    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
//        let (sut, primaryLoader, fallbackLoader) = makeSUT()
//        
//        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
//            primaryLoader.complete(with: anyNSError())
//            fallbackLoader.complete(with: anyNSError())
//        })
//    }
//
//    // MARK: - Helpers
//    
//    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
//        let primaryLoader = LoaderSpy()
//        let fallbackLoader = LoaderSpy()
//        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
//        trackForMemoryLeaks(primaryLoader, file: file, line: line)
//        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return (sut, primaryLoader, fallbackLoader)
//    }
//    
//    // With Stubs, we set the values Upfront
//    // With Spys, we capture the values, so we can use them later
//    private class LoaderSpy: FeedImageDataLoader {
//        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
//
//        private(set) var cancelledURLs = [URL]()
//
//        var loadedURLs: [URL] {
//            return messages.map { $0.url }
//        }
//
//        private struct Task: FeedImageDataLoaderTask {
//            let callback: () -> Void
//            func cancel() { callback() }
//        }
//
//        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
//            messages.append((url, completion))
//            return Task { [weak self] in
//                self?.cancelledURLs.append(url)
//            }
//        }
//        
//        func complete(with error: Error, at index: Int = 0) {
//            messages[index].completion(.failure(error))
//        }
//        
//        func complete(with data: Data, at index: Int = 0) {
//            messages[index].completion(.success(data))
//        }
//    }
//    
//}

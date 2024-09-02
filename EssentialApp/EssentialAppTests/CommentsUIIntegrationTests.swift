//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/9/24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import Foundation
import EssentialApp
import Combine

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {

    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }

    // We make all the assertions of the loadCallCount due to the TEMPORAL COUPLING on one place. The order of the methods called rely on the View Cycle, something that's out of our control. So better to centralize this on one test, where more of one assertion on the test is recommended
    
    // We are being explicit with the progress of the expectations and the order.
    
    // Working with frameworks, we don't have control over Temporal Coupling. We work with framework events, that we don't have the control of how they will behave in the future. So explicitly we indicate the order of them in one single test, to help the reader in future iterations.
    
    // It can help to avoid mistakes to have all the assertions for temporal coupling in one test
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected first loading requests before view is loaded")
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected second loading requests before view is loaded")
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected third loading requests before view is loaded")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Expected showing loading indicator")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Expected showing loading indicator")
        
        loader.completeCommentsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
        
        sut.simulateUserInitiatedReload()
        
        loader.completeCommentsLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
    }
    
    override func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
    }
    
    override func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        sut.simulateAppearance()
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
        let image0 = makeImage(description: "description 0", location: "location 0")
        let image1 = makeImage(description: nil, location: "location 1")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        // Test-specific DSL Methods decouple the test from implementation details such as UITableView, this way wou can freely and safely refactor production code, such as switching to a UICollectionView in the future without breaking the tests. The goal is to test behaviour, not implementation
        
        // 0 CASE
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        
        loader.completeCommentsLoading(with: [image0], at: 0)
        
        // ONE ELEMENT CASE
        assertThat(sut, isRendering: [image0])
    
        sut.simulateUserInitiatedReload()
        
        let arrayManyCase = [image0, image1, image2, image3]
        loader.completeCommentsLoading(with: arrayManyCase, at: 1)
        
        // MANY ELEMENT CASE
        assertThat(sut, isRendering: arrayManyCase)
    }
    
    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "description 0", location: "location 0")
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
   
   
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
   
    
    
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeCommentsLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertFeedCellModelFor(view: FeedImageCell?, feed: FeedImage) {
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, true)
        XCTAssertEqual(view?.locationText, feed.location)
        XCTAssertEqual(view?.descriptionText, feed.description)
    }
    
    class LoaderSpy {
        
        // MARK: - FeedLoader
        
        private var commentsRequests = [PassthroughSubject<[FeedImage], Error>]()
        
        var loadCommentsCallCount: Int {
            return commentsRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            commentsRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            commentsRequests[index].send(feed)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            commentsRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }

}

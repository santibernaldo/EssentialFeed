//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/5/24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import Foundation

/*
 UX Inbox
 
 [✅] Load feed automatically when view is presented
 [✅] Allow customer to manually reload feed (pull to refresh)
 [✅] Show a loading indicator while loading feed
 [✅] Render all loaded feed items (location, image, description)
 [ ] Image loading experience
     [ ] Load when image view is visible (on screen)
     [ ] Cancel when image view is out of screen
     [ ] Show a loading indicator while loading image (shimmer)
     [ ] Option to retry on image download error
     [ ] Preload when image view is near visible
 */

final class FeedViewControllerTests: XCTestCase {
    
    // We make all the assertions of the loadCallCount due to the TEMPORAL COUPLING on one place. The order of the methods called rely on the View Cycle, something that's out of our control. So better to centralize this on one test, where more of one assertion on the test is recommended
    
    // We are being explicit with the progress of the expectations and the order.
    
    // Working with frameworks, we don't have control over Temporal Coupling.
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 0, "Expected no loading requests before view is loaded")
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 1, "Expected first loading requests before view is loaded")
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 2, "Expected second loading requests before view is loaded")
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 3, "Expected third loading requests before view is loaded")
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 1)
    }
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadFeedRequestCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingTheFeed() {
        let (sut, loader) = makeSUT()

        // viewDidLoad
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        // When UIRefreshControl refreshes, it shows a Loading Indicator
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Expected showing loading indicator")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator(), true, "Expected showing loading indicator")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError()
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected not showing loading indicator")
    }
    
    func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
        let image0 = makeImage(description: "description 0", location: "location 0")
        let image1 = makeImage(description: nil, location: "location 1")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        // Test-specific DSL Methods decouple the test from implementation details such as UITableView, this way wou can freely and safely refactor production code, such as switching to a UICollectionView in the future without breaking the tests. The goal is to test behaviour, not implementation
        
        // 0 CASE
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        
        loader.completeFeedLoading(at: 0, with: [image0])
        
        // ONE ELEMENT CASE
        assertThat(sut, isRendering: [image0])
    
        sut.simulateUserInitiatedFeedReload()
        
        let arrayManyCase = [image0, image1, image2, image3]
        loader.completeFeedLoading(at: 0, with: arrayManyCase)
        
        // MANY ELEMENT CASE
        assertThat(sut, isRendering: arrayManyCase)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "description 0", location: "location 0")
        
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(at: 0, with: [image0])
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
    }
    

    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
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
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        private var completionsFeedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedRequestCallCount: Int {
            return completionsFeedRequests.count
        }
        
        func completeFeedLoading(at index: Int = 0, with feed: [FeedImage] = []) {
            completionsFeedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completionsFeedRequests[index](.failure(error))
        }
        
        // MARK: - FeedLoader
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completionsFeedRequests.append(completion)
        }
        
        // MARK: - FeedImageDataLoader
        
        private(set) var loadedImageURLs = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }
}

// DSL test-specific methods which abstract from implementation details
extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        replaceRefreshControlWithFakeForiOS17Support()
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func simulateFeedImageViewVisible(at index: Int) {
        _ = feedImageView(at: index)
    }
}

// DSL test-specific methods for FeedImageCell which abstracts from implementation details
extension FeedImageCell {
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UITableViewController {
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefresing = false
    
    override var isRefreshing: Bool { _isRefresing }
    
    override func beginRefreshing() {
        _isRefresing = true
    }
    
    override func endRefreshing() {
        _isRefresing = false
    }
}

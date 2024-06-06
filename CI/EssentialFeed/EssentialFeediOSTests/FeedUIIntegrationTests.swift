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
 [ ✅] Image loading experience
     [✅] Load when image view is visible (on screen)
     [✅] Cancel when image view is out of screen
     [✅] Show a loading indicator while loading image (shimmer)
     [✅] Renders image loaded from URL
     [✅] Option to retry on image download error
     [✅] Preload when image view is near visible
 */

final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_TITLE_VALUE"))
    }

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
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
        
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
    
    //[✅ ] Load when image view is visible (on screen)
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
    
   // [✅] Cancel when image view is out of screen
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    // [✅] Renders image loaded from URL
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        // We prepare an invalid Image Data
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
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
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
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
            
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url)
            }
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

// DSL test-specific methods which abstract from implementation details
extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        replaceRefreshControlWithFakeForiOS17Support()
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshController?.view?.isRefreshing == true
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
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        // Called when view is no longer visible on the table view
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
}

// DSL test-specific methods for FeedImageCell which abstracts from implementation details
extension FeedImageCell {
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
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

private extension FeedViewController {
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshController?.view?.allTargets.forEach { target in
            refreshController?.view?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshController?.view = fake
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


private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

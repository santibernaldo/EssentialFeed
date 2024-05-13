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
 [ ] Render all loaded feed items (location, image, description)
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
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expected first loading requests before view is loaded")
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2, "Expected second loading requests before view is loaded")
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expected third loading requests before view is loaded")
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = makeSUT()
                
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 3)
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
    }
    
    func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
        let image = makeImage()
        let (sut, loader) = makeSUT()
        
        // View Will Appear is called
        sut.beginAppearanceTransition(true, animated: false) //viewWillAppear
        // ViewIsAppearing and View Did Appear
        sut.endAppearanceTransition()
        
        // Test-specific DSL Methods decouple the test from implementation details such as UITableView, this way wou can freely and safely refactor production code, such as switching to a UICollectionView in the future without breaking the tests. The goal is to test behaviour, not implementation
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        
        loader.completeFeedLoading(at: 0, with: [image])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1)
    }
        
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int, with feed: [FeedImage] = []) {
            completions[index](.success(feed))
        }
    }
}

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

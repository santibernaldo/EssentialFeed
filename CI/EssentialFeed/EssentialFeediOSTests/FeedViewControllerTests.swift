//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/5/24.
//

import XCTest
import UIKit
import EssentialFeed
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

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        loader?.load(completion: { _ in })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        // When valueChanged action of refreshControl is called, we perform load
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> ()) {
            loadCallCount += 1
        }
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

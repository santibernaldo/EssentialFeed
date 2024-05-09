//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/5/24.
//

import XCTest
import UIKit

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

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
    
}

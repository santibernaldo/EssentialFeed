//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/5/24.
//

import XCTest

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

final class FeedViewController {
    let loader: LocalFeedLoader
    
    init(loader: LocalFeedLoader) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
    
}

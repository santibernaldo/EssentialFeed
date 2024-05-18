//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 18/5/24.
//

import EssentialFeed

// ViewModel are agnostic platform, they don't know about the view
final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    // We notify the observer every time there's a state change
    private var state = State.pending {
        didSet { onChange?(self) }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var feed: [FeedImage]? {
        switch state {
        case let .loaded(feed):
            return feed
        case .pending, .loading, .failed:
            return nil
        }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading:
            return true
        case .pending, .loaded, .failed:
            return false
        }
    }
    
    func loadFeed() {
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}

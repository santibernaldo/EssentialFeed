//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 18/5/24.
//

import EssentialFeed

// ViewModel are agnostic platform, they don't know about the view
final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // We notify the observer every time there's a state change
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            
            self?.onLoadingStateChange?(false)
        }
    }
}

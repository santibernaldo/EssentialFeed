//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 18/5/24.
//

import EssentialFeed
import Combine

// ViewModel are agnostic platform, they don't know about the view

// This ViewModel is Platform Agnostic, it can be used on many platforms

// View Model has dependencies and behaviour, that's different from View Presenter
public final class FeedMVVM {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    
    public init(feedLoader: AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    // We notify the observer every time there's a state change
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        
        cancellable = feedLoader.sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.onLoadingStateChange?(false)
                }
            }, receiveValue: { [weak self] feed in
                self?.onFeedLoad?(feed)
            })
    }
}

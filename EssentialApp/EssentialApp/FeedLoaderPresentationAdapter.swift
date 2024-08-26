//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    
    // FeedPresenter expects an array of Feed to be passed to the view, so the FeedLoaderPresentationAdapter communicates with the FeedLoader to get this data and pass it to the view through the presenter
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        // We must hold the cancellable, if we don't it would be deallocated. And the whole suscription is cancelled
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
    }
}

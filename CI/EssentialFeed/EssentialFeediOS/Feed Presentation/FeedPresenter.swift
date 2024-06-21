//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 24/5/24.
//

//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 18/5/24.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedPresenterViewModel {
    let feed: [FeedImage]
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

struct FeedPresenterImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedView {
    func display(_ viewModel: FeedPresenterViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    var feedView: FeedView
    var loadingView: FeedLoadingView
    var errorView: FeedErrorView
    
    static var title: String {
        return "My Feed"
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(FeedErrorViewModel.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedPresenterViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}


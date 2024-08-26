//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/6/24.
//

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let errorView: ResourceErrorView
    private let loadingView: FeedLoadingView
    
    public init(feedView: FeedView,
         errorView: ResourceErrorView,
         loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_TITLE_VALUE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    // Void -> creates view models -> sends to the UI
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    // [FeedImage] -> creates view models -> sends to the UI
     public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    // Error -> creates view models -> sends to the UI
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}

//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/5/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
    
        let feedController = FeedViewController.makeWith(title: FeedPresenter.title)
        
        let refreshController = feedController.refreshController!
        refreshController.delegate = presentationAdapter
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)), errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(refreshController))
        
        return feedController
    }

//    public static func feedComposedViewModel(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewModelViewController {
//        let feedViewModel = FeedMVVM(feedLoader: feedLoader)
//        let refreshController = FeedRefreshViewModelViewController(viewModel: feedViewModel)
//        let feedController = FeedViewModelViewController(refreshController: refreshController)
//        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
//        return feedController
//    }
//    
//    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewModelViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
//        return { [weak controller] feed in
//            controller?.tableModel = feed.map { model in
//                FeedImageViewModelCellController(viewModel:
//                                            FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
//            }
//        }
//    }
}

private extension FeedViewController {
    static func makeWith(title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = title
        return feedController
    }
}









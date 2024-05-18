//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/5/24.
//

import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    static public func composedFeedController(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: loader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh  = adaptFeedCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    // [FeedImage] -> Adapt -> FeedImageCellController
    private static func adaptFeedCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                return FeedImageCellController(imageLoader: loader, model: model)
            }
        }
    }
}

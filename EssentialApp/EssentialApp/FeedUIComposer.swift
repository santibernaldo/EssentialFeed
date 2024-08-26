//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/5/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: { feedLoader().dispatchOnMainQueue() })
        
        let feedController = FeedViewController.makeWith(
            title: FeedPresenter.title)
        
        let refreshController = feedController.refreshController!
        refreshController.delegate = presentationAdapter
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }

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









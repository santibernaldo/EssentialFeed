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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        
        let feedController = ListViewController.makeWith(
            title: FeedPresenter.title)
        
        // When 'loadResource' is Called, it triggers the 'onRefresh'
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader,
            selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }

}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}









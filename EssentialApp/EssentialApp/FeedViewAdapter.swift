//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

// FeedViewAdapter

// // [FeedImage] -> creates view models -> sends to the UI
final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        // the object passed onto the display method as parameter is the data expected by the controller
        let feedImageCellControllers = getImageCellControllers(viewModel: viewModel, imageLoader: imageLoader)
        
        controller?.display(feedImageCellControllers)
    }
    
    func getImageCellControllers(viewModel: FeedViewModel, imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
        viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

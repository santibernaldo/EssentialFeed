//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

// FeedViewAdapter

// // [FeedImage] -> creates view models -> sends to the UI
final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        // the object passed onto the display method as parameter is the data expected by the controller
        let feedImageCellControllers = getImageCellControllers(viewModel: viewModel, imageLoader: imageLoader)
        
        controller?.display(feedImageCellControllers)
    }
    
    func getImageCellControllers(viewModel: FeedViewModel, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> [CellController] {
        viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            // View is a FeedImageCellController, which implements all the protocols of the tuple contained in CellController. So we can pass all of them
            return CellController(view)
        }
    }
}

extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}


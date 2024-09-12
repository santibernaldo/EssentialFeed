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
    private let selection: (FeedImage) -> Void
    // STAR: Lookup Table, so we match the feedImage against the CellController, if we got a CellController already created for that FeedImage, we don't create it again
    private let currentFeed: [FeedImage: CellController]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    // STAR: The view type (FeedViewAdapter) cause its loading a Feed
    // ASK Program:     
    // STAR: The view type (FeedViewAdapter) cause its loading a Feed
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(currentFeed: [FeedImage: CellController] = [:], controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = controller else { return }
        
        // the object passed onto the display method as parameter is the data expected by the controller
        var currentFeed = self.currentFeed

        let feed = viewModel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }
                        
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            // View is a FeedImageCellController, which implements all the protocols of the tuple contained in CellController. So we can pass all of them
            let controller = CellController(id: model, view)
            currentFeed[model] = controller
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }
        
        // STAR: The load resource in the adaptr is the one where we call the 'loadMorePublisher'
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        
        // STAR: Every time there's a new callback (willdisplay is triggered), it will call loadMore.
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        // STAR: All the State transitions handled on the Presenter
        // STAR: With the Presentation adapter, we get all the behaviour a ResourceLoading for free, we just reuse all that logic here. We just compose it with a new CellController
        
        // TODO: Check why FeedViewAdapter is here as parameter (almost last video on the end)
        // TODO: Check the use of Adapters and Presenter Adapter
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                currentFeed: currentFeed,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            // ASK Program (1: 20 video keyset pagination)
            mapper: { $0 } )
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller.display(feed, loadMoreSection)
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


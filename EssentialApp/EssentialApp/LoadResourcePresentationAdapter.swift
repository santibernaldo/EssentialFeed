//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import EssentialFeed
import EssentialFeediOS
import Combine

// STAR: Every Resource we loads (images, feed, comments) goes through this Presentation Adapter
final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    // LoadResourcePresenter expects a Reource to be passed to the view, so the LoadResourcePresentationAdapter communicates with the Loader to get thie Resource and pass it to the view through the presenter
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    private var isLoading = false

    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }

        presenter?.didStartLoading()
        isLoading = true
        
        // We must hold the cancellable, if we don't it would be deallocated. And the whole suscription is cancelled
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                    
                    self?.isLoading = false
                }, receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                })
    }
}


extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}

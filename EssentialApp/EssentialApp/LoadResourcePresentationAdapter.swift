//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/6/24.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    // LoadResourcePresenter expects a Reource to be passed to the view, so the LoadResourcePresentationAdapter communicates with the Loader to get thie Resource and pass it to the view through the presenter
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        // We must hold the cancellable, if we don't it would be deallocated. And the whole suscription is cancelled
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
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

//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 29/7/24.
//

import EssentialFeed

// compose objects that share a common interface with the Composite Design Pattern as we implement the fallback logic for the feed and image data loaders.
class FeedLoaderWithFallbackComposite: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

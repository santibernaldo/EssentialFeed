//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/8/24.
//

import EssentialFeed

// With Stubs, we set the values Upfront
// With Spys, we capture the values, so we can use them later
private class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}

//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/5/24.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

// Ideally we would have one method per protocol to respect the INTERFACE SEGREGATION PATTERN

// Abstraction over a Core Feature of the Feed Feature module. Doesn't belong to the UI, or the Presentation module
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

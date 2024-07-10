//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/7/24.
//

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

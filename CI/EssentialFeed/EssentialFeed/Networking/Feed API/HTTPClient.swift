//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 27/2/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

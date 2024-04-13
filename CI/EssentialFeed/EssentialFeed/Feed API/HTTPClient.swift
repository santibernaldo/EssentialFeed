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

// A contract which helps being implemented without the cration of a specific type, so we could create an extension of Alamofire, URLSession, or any other networking third-party framework 
public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropiate thread, if needed
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

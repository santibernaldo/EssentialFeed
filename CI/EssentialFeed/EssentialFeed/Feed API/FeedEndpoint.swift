//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/9/24.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            // STAR: We force unwrap here, but it would be a developer mistake if it happens
            // STAR: The unit test will fail, if we pass anything wrong
            // test_feed_endpointURL
            return components.url!
        }
    }
}

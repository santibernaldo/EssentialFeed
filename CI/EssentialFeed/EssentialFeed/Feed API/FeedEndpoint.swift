//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/9/24.
//

import Foundation

/*
 [✅]FIRST: GET/feed?limit=10
 Load More: GET /feed?limit=10&after_id={last_id}
 */

public enum FeedEndpoint {
    // STAR: Same endpoint but with optional parameters, that's why we don't create a new case
    case get(after: FeedImage? = nil)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(image):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) },
            ].compactMap { $0 }
            // STAR: We force unwrap here, but it would be a developer mistake if it happens
            // STAR: The unit test will fail, if we pass anything wrong
            // test_feed_endpointURL
            // STAR: We wouldn't want to do this if we receive this baseURL from API request (the baseURL we're using is static)
            return components.url!
        }
    }
}

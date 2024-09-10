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
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}

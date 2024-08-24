//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 24/8/24.
//
import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}

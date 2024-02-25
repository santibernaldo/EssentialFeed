//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Santi Bernaldo on 26/12/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    var description: String?
    let location: String?
    let imageURL: URL
}

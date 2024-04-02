//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

// DTO - Data Transfer Object representation, to decouple Models from different modules and avoid breaking changes between them
public struct LocalFeedItem: Equatable {
    public let id: UUID
    public var description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}


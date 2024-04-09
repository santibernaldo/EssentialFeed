//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 2/4/24.
//

// DTO - Data Transfer Object representation, to decouple Models from different modules and avoid breaking changes between them
// We don't implement Codable here, so this model is agnostic of the Framework for persistence we're using, Codable, CoreData..
public struct LocalFeedImage: Equatable {
    public let id: UUID
    public var description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}


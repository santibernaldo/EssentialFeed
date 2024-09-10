//
//  FeedImagePresenterViewModel.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/6/24.
//

public struct FeedImageViewModel {
    
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
    
    public init(description: String? = nil, location: String? = nil) {
        self.description = description
        self.location = location
    }
}

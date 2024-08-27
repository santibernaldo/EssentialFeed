//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 26/8/24.
//

public struct ResourceErrorViewModel {
    
    public let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}

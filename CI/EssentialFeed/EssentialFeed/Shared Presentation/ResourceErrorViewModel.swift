//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 26/8/24.
//

public struct ResourceErrorViewModel {
    public let message: String?

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}

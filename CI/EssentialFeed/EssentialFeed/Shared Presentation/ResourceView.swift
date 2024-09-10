//
//  ResourceView.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 26/8/24.
//

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

//
//  FeedUIIntegrationTEsts+Localization.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 26/8/24.
//


import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    public var feedTitle: String {
        FeedPresenter.title
    }
}

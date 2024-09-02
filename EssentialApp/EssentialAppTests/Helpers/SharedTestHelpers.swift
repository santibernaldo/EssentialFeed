//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/7/24.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

public var feedTitle: String {
    FeedPresenter.title
}

public var commentsTitle: String {
    ImageCommentsPresenter.title
}

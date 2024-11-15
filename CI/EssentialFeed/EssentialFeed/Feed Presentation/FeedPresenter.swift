//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/6/24.
//

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public final class FeedPresenter {
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}

//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/4/24.
//

import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func makeUniqueFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localFeed = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (feed, localFeed)
}

extension Date {
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    /*
     DSL Date.minusFeedCacheMaxAge API hides implementation details about calculating the max cache age, and provides a clear context in the domain of the 'Feed Cache'.
     
     The Date class doesn't normally know anything about "caching Feed objects", so the extension minusFeedCacheMaxAge was added to it so that function can be called on any valid Date object.

     You could say that the minusFeedCacheMaxAge function is "domain-specific language" for working with cached objects.
     */
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    // A Date represents a time interval
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

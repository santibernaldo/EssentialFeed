//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 7/4/24.
//

// Policy/Rules business model separated from the UseCase ´LocalFeedLoader´which is acting as an Interactor/Controller (Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles from Modulo 2)

// This is a Business Rule that can be used across Applications, Use Cases

// This one was extracted from the LocalFeedLoader, the code was moved around, it was a refactor

// only encapsulates the feed cache validation policy/rules)

//MARK: - Value Object (Not an Entity with a property which identifies the model)
internal final class FeedCachePolicy {
    // It holds no state, it's a Value Object. So we can make their properties and methods statics
    private init() {}
    
    // If a Value Type holds no state (in our case, the FeedCachePolicy only encapsulates the feed cache validation policy/rules), it can be replaced by static or free functions.
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = FeedCachePolicy.calendar.date(byAdding: .day, value: FeedCachePolicy.maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

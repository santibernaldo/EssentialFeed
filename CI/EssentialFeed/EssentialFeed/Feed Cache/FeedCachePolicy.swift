//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 7/4/24.
//

// Policy/Rules business model separated from the UseCase ´LocalFeedLoader´which is acting as an Interactor/Controller (Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles from Modulo 2)
internal final class FeedCachePolicy {
    private init() {}
    
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

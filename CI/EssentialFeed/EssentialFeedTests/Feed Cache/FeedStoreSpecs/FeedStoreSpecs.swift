//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/4/24.
//

// These are Specs that are meant to be implemented by other clients, we should break the assertions inside the tests into to tests

//  Future implementations of the FeedStoreSpecs protocol that can’t fail, e.g., an in-memory store, would end up with empty implementations for these methods.
protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws
    func test_delete_emptiesPreviouslyInsertedCache() throws
    
    func test_storeSideEffects_runSerially() throws
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError() throws
    func test_retrieve_hasNoSideEffectsOnFailure() throws
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError() throws
    func test_insert_hasNoSideEffectsOnInsertionError() throws
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError() throws
    func test_delete_hasNoSideEffectsOnDeletionError() throws
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

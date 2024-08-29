//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/8/24.
//

import UIKit
import EssentialFeediOS

// DSL test-specific methods which abstract from implementation details

/*
 DSL stands for Domain-Specific Language. It's a broad topic, but in this context, it's a technique for modeling APIs tailored to a particular domain.

 The idea is to create simple and clear APIs that make it easier to understand the domain without exposing implementation details.

 For example, the Date.minusFeedCacheMaxAge API hides implementation details about calculating the max cache age, and provides a clear context in the domain of the 'Feed Cache'.
 */
extension ListViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
                    return nil
                }
        
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        // Called when view is no longer visible on the table view
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var errorMessage: String? {
        errorView.message 
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        // Transfering actions from the refreshControl to the fakeOne
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        // View Will Appear is called
        beginAppearanceTransition(true, animated: false)
        // ViewIsAppearing and View Did Appear
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefresing = false
    
    override var isRefreshing: Bool { _isRefresing }
    
    override func beginRefreshing() {
        _isRefresing = true
    }
    
    override func endRefreshing() {
        _isRefresing = false
    }
}

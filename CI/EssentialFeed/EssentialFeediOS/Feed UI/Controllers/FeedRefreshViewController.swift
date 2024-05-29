//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/5/24.
//

import UIKit
import EssentialFeed

// We must inherit from NSObject to implement the target/action, that's why we don't move the addTarget to the ViewModel, to keep it agnostic platform
final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    // Legacy: make private for testing purposes
    private(set) lazy var view = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
        
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}

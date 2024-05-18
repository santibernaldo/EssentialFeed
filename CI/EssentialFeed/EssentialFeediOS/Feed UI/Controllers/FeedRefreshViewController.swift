//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/5/24.
//

import UIKit
import EssentialFeed

// We must inherit from NSObject to implement the target/action, that's why we don't move the addTarget to the ViewModel, to keep it agnostic platform
final public class FeedRefreshViewController: NSObject {
    public lazy var view = binded(UIRefreshControl())
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
        
    @objc public func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        // Binds ViewModel with the View
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        // Binds the View with the ViewModel
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}

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
    @IBOutlet public var view: UIRefreshControl?
    
    public var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        view?.update(isRefreshing: viewModel.isLoading)
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}

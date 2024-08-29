//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/5/24.
//


import UIKit
import EssentialFeed

// STAR: Every protocol with one method can be replaced with a closure
//public protocol FeedViewControllerDelegate {
//    func didRequestFeedRefresh()
//}

// old view, preload and cancelLoad, shared a common interface between UIKit, that's why we moved onto UIKit specific protocols
public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    @IBOutlet public weak var errorView: ErrorView?
    
    public var onRefresh: (() -> Void)?
    
    // Keeping track of the cell controllers shown on screen, to cancel the image loading on them
    private var loadingControllers = [IndexPath: CellController]()
    private var viewAppeared = false

    private var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
        tableView.prefetchDataSource = self
    }
    
    // iOS 13+
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewAppeared {
            viewAppeared = true
            refresh()
        }
        
    }
    
    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
        
    public func display(_ viewModel: ResourceErrorViewModel) {
        if let message = viewModel.message {
            errorView?.show(message: message)
        } else {
            errorView?.hideMessage()
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // The controller is dispatching cellForRow at each cell
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    /*
     When updating the table model and reloading the table, UIKit calls didEndDisplayingCell for each removed cell that was previously visible. Since we're canceling requests in this method, we could be sending messages to the new models or potentially crashing in case the new table model has fewer items than the previous one!

     This is not a big problem at the moment since items cannot be removed from the feed. But we cannot assume the backend will keep this behavior going further.
     */
    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}

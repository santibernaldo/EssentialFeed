//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/5/24.
//

import UIKit
import EssentialFeed
import Foundation

public final class FeedUIComposer {
    
    private init() {}
    
    static public func composedFeedController(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: loader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh  = adaptFeedCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    // [FeedImage] -> Adapt -> FeedImageCellController
    private static func adaptFeedCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                return FeedImageCellController(imageLoader: loader, model: model)
            }
        }
    }
}


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshController: FeedRefreshViewController?
    private var feedImageLoader: FeedImageDataLoader?
    
    var tableModel: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
            
        tableView.prefetchDataSource = self

    }
    
    // iOS 13+
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
        
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancel()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
}

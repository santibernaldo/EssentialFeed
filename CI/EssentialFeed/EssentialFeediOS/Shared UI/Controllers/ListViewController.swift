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
// STAR: dataSource is not optional as is Mandatory its use

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    private(set) public var errorView = ErrorView()
    
    public var onRefresh: (() -> Void)?
    
    private var viewAppeared = false

    // STAR: Every time we update the tableModel, we update the whole table view, so we don't want that. We need a DiffableDataSource
    // STAR: The Diffable should be Hashable, so the Diffable can compare any change found in the model
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, index, controller) in
            controller.dataSource.tableView(tableView, cellForRowAt: index)
        }
    }()
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }

    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
        tableView.prefetchDataSource = self
        tableView.tableHeaderView = errorView.makeContainer()
        
        errorView.onHide = { [weak self] in
            guard self != nil else { return }
            self?.tableView.beginUpdates()
            // When the Height of the Header changes, we need to update the Header Size manually
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    // iOS 13+
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewAppeared {
            viewAppeared = true
            refresh()
        }
        
    }
    
    // STAR: Dynamic font type with Diffable Data Source.
    // We listen to changes to Dynamic Type, and we reload the tableView manually
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        // Only when we append the section, the dataSource knows the number of sections. Otherwise, its zero
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        // On iOS 14 and before, calling apply(snapshot, animatingDifferences: false) would call reloadData on the table/collection view and reload all cells. And calling apply(snapshot, animatingDifferences: true) would perform a diff on the data source and only update cells that the data changed.
        
        //But on iOS 15+, passing false or true in animatingDifferences will perform a diff and only update cells that the data changed.
        if #available(iOS 15.0, *) {
          dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
          dataSource.apply(snapshot)
        }
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
        
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let dl = cellController(at: indexPath)?.delegate
      dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    
}

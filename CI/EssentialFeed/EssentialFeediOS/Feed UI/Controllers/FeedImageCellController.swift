//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 17/5/24.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private let delegate: FeedImageCellControllerDelegate
    // STAR: FeedImageCellController only knows about FeedImageViewModel, so we pass the closure without the FeedImage type
    private let selection: () -> ()
    private var cell: FeedImageCell?
    
    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate, selection: @escaping () -> Void) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.selection = selection
    }
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
        
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = nil
        
        // STAR: Because the animation of the ErroView dismiss, it can holds the instance longer than it should in memory. And it causes back in production
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        delegate.didRequestImage()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell = cell as? FeedImageCell
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
 
extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}

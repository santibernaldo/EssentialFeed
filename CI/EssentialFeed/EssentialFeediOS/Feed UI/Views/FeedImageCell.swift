//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/5/24.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    static let identifier: String = "FeedImageCellIdentifier"
    
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var feedImageRetryButton: UIButton!
   
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
    
    /*STAR:
     On iOS 15+, for performance reasons, the table view data source may create cells ahead of time using the cellForRow method. But those cells created ahead of time may never be displayed on the screen (if the user never scrolls to them, for example). So the cell may be created but never go through the whole willDisplayCell/didEndDisplaying lifecycle callbacks as it may never be displayed.

     There can be a cell reuse issue in such cases because we start loading the cell image on cellForRow and only cancel the request on didEndDisplaying. And if didEndDisplaying is never called, there can be a race condition when reusing the cell because the request would not stop and potentially load the wrong image at the wrong index path.

     To fix it, we need to release the FeedImageCellController's cell reference on prepareForReuse.
     */
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
}

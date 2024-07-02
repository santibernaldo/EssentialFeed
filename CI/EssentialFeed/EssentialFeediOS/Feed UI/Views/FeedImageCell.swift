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
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}

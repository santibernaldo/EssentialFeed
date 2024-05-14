//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 13/5/24.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    static let identifier: String = "FeedImageCellIdentifier"
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    public let feedImageRetryButton = UIButton()
}

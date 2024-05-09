//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/5/24.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.6,
            options: [],
            animations: {
                self.feedImageView.alpha = 1
            }, completion: { completed in
                
            })
    }
    
}

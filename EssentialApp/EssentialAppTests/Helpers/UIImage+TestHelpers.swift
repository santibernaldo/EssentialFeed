//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 6/8/24.
//

import UIKit

extension UIImage {
    //On iOS 16.1, comparing images generated with the UIImage.make(color:) helper started to fail due to differences in the image scale when converting it to pngData. To prevent this issue, you need to update the UIImage.make(color:) helper implementation to set a fixed scale of 1.
    
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

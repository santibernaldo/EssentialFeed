//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/8/24.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

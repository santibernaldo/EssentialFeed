//
//  UITableView+Dequeueing.swift .swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 29/5/24.
//


import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}

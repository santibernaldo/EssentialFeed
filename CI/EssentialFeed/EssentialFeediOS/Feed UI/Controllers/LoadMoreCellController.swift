//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/9/24.
//

import Foundation
import UIKit
import EssentialFeed


public class LoadMoreCellController: NSObject, UITableViewDataSource {
    private let cell = LoadMoreCell()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

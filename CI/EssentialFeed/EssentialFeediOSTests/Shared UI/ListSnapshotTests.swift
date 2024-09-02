//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 28/8/24.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())

        // We look for the same folder where the test file is located, and 'snapshots' folder images are located
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraLarge)), named: "LIST_WITH_ERROR_MESSAGE_light_extraExtraLarge")
    }
    
    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        // This setting is a requirement that can be changed per client, so we test it here, its a test detail
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() -> [CellController] {
        return []
    }
    
}

//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 29/8/24.
//

import XCTest
@testable import EssentialFeediOS
import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_DARK")
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    // STAR: 3 comments CellController, one with SHORT TEXT, one with MEDIUM TEXT, one with LONG TEXT
    private func comments() -> [CellController] {
            return [
                ImageCommentCellController(
                    model: ImageCommentViewModel(
                        message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                        date: "1000 years ago",
                        username: "a long long long long username"
                    )
                ),
                ImageCommentCellController(
                    model: ImageCommentViewModel(
                        message: "East Side Gallery\nMemorial in Berlin, Germany",
                        date: "10 days ago",
                        username: "a username"
                    )
                ),
                ImageCommentCellController(
                    model: ImageCommentViewModel(
                        message: "nice",
                        date: "1 hour ago",
                        username: "a."
                    )
                ),
            ]
        }
    
}

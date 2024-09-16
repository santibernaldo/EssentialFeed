//
//  XCTestCase-FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 3/8/24.
//

import XCTest
import EssentialFeed

protocol FeedImageLoaderTestCase: XCTestCase {}

extension FeedImageLoaderTestCase {
    
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedFeed), .success(expectedFeed)):
            XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            
        case (.failure, .failure):
            break
            
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
}

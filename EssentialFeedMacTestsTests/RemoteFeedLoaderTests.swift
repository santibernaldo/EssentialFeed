//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedMacTestsTests
//
//  Created by Santi Bernaldo on 28/12/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "http://agivenurl.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init () {}
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_loadRequestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
    }

}

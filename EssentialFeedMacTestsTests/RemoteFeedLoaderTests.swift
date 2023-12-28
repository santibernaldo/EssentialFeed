//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedMacTestsTests
//
//  Created by Santi Bernaldo on 28/12/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.load(url: URL(string: "http://agivenurl.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
        
    func load(url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
        
    override func load(url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoesNotRequestDataFromURL() {
        let clientSpy = HTTPClientSpy()
        
        HTTPClient.shared = clientSpy
        
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(clientSpy.requestedURL)
    }
    
    func test_loadRequestDataFromURL() {
        let clientSpy = HTTPClientSpy()
        
        HTTPClient.shared = clientSpy
        
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(clientSpy.requestedURL)
        
    }

}

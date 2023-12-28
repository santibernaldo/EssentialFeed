//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedMacTestsTests
//
//  Created by Santi Bernaldo on 28/12/23.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.load(url: URL(string: "http://agivenurl.com")!)
    }
}

protocol HTTPClient {
    func load(url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
        
    func load(url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoesNotRequestDataFromURL() {
        let clientSpy = HTTPClientSpy()
                
        let _ = RemoteFeedLoader(client: clientSpy)
        
        XCTAssertNil(clientSpy.requestedURL)
    }
    
    func test_loadRequestDataFromURL() {
        let clientSpy = HTTPClientSpy()
                
        let sut = RemoteFeedLoader(client: clientSpy)
        
        sut.load()
        
        XCTAssertNotNil(clientSpy.requestedURL)
        
    }

}

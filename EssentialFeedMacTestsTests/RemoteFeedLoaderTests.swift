//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedMacTestsTests
//
//  Created by Santi Bernaldo on 28/12/23.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL = URL(string: "http://agivenurl.com")!) {
        self.client = client
        self.url = url
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
        let url = URL(string: "http://agivenurl.com")!
                
        let sut = RemoteFeedLoader(client: clientSpy, url: url)
        
        sut.load()
        
        XCTAssertEqual(clientSpy.requestedURL, url)
        
    }

}

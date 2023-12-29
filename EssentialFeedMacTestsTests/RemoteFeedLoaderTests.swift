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
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.load(url: url)
    }
}

protocol HTTPClient {
    func load(url: URL)
}



final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoesNotRequestDataFromURL() {
        let url = URL(string: "http://agivenurl.com")!
                
        let (_, client) = makeSUT(url: url)
                
        XCTAssertNil(client.requestedURL)
    }
    
    func test_loadRequestDataFromURL() {
        let url = URL(string: "http://agivenurl.com")!
                
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    private func makeSUT(url: URL) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        return (remoteFeedLoader, client)
    }
                      
                      
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
            
        func load(url: URL) {
            requestedURL = url
        }
    }
}

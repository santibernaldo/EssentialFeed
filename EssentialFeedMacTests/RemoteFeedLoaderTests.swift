//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedMacTestsTests
//
//  Created by Santi Bernaldo on 28/12/23.
//

import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertTrue(client.requestedURLS.isEmpty)
    }
    
    func test_load_RequestDataFromURL() {
        let url = URL(string: "http://agivenurl.com")!
                
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        // When asserting objects collaborating, is not enough to test the values passed, but we need to ask how many times was the method invoked
        XCTAssertEqual(client.requestedURLS, [url])
    }
    
    // We test that 'load' is only called once from the RemoteFeedLoader, using the client. Cause this code can gets duplicated during merge or other situations, and we are bound to avoid that.
    func test_loadTwice_RequestDataFromURL() {
        let url = URL(string: "http://agivenurl.com")!
                
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        // When asserting objects collaborating, is not enough to test the values passed, but we need to ask how many times was the method invoked
        XCTAssertEqual(client.requestedURLS, [url, url])
    }
    
    private func makeSUT(url: URL = URL(string: "http://agivenurl.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        return (remoteFeedLoader, client)
    }
                      
                      
    private class HTTPClientSpy: HTTPClient {
        var requestedURLS = [URL]()
            
        func load(url: URL) {
            requestedURLS.append(url)
        }
    }
}

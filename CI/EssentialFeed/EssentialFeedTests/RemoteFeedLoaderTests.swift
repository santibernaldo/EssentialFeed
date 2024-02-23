//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Santi Bernaldo on 23/2/24.
//

import XCTest
import EssentialFeed

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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load {
            capturedErrors.append($0)
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    private func makeSUT(url: URL = URL(string: "http://agivenurl.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        return (remoteFeedLoader, client)
    }
                      
                      
    private class HTTPClientSpy: HTTPClient {
        var requestedURLS = [URL]()
        var completions = [(Error) -> Void]()
        
        func load(url: URL, completion: @escaping (Error) -> Void) {
            
            // We're not stubbing, from the test (setting the error manually), min 6:53 from 'Handling Errors Invalid Paths', hence we're not creating behaviour here, checking if we got some error unwrapping if
            /*
             
             Avoiding:
             
             if let error = error {
                completion(error)
             }
             
             We only keep an array of completions with the Error.
             
             And how the code changes from the Arrange to the Act section
             
             */
            
           
            // We just accumulate all the properties we recieve
            completions.append(completion)
            requestedURLS.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
    
    

}

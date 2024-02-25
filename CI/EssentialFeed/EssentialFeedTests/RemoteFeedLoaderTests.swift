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
        
        sut.load { _ in }
        
        // When asserting objects collaborating, is not enough to test the values passed, but we need to ask how many times was the method invoked
        XCTAssertEqual(client.requestedURLS, [url])
    }
    
    // We test that 'load' is only called once from the RemoteFeedLoader, using the client. Cause this code can gets duplicated during merge or other situations, and we are bound to avoid that.
    func test_loadTwice_RequestDataFromURL() {
        let url = URL(string: "http://agivenurl.com")!
                
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        // When asserting objects collaborating, is not enough to test the values passed, but we need to ask how many times was the method invoked
        XCTAssertEqual(client.requestedURLS, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity, when:  {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithError: .invalidData) {
            let invalidJSON = Data()
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // The SPY is only CAPTURING values, as we like
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLS: [URL] {
            return messages.map { $0.url }
        }
 
        // We just want to complete, one time per request, that's why we use arrays to assert that on the test
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLS[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            
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
            messages.append((url, completion))
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://agivenurl.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        return (remoteFeedLoader, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
                
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }

}

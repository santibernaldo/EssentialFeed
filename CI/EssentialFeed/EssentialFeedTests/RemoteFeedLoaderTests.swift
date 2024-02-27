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
        
        expect(sut, toCompleteWith: .failure(.connectivity), when:  {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data()
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    // Happy path here
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut,
               toCompleteWith: .success(items),
               when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200,
                            data: json)
        })
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
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
            
           
            // We just accumulate all the properties we receive
            messages.append((url, completion))
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://agivenurl.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: url)
        
        return (remoteFeedLoader, client)
    }
    
    // Factory FeedItem
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

}

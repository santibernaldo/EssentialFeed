//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 9/7/24.
//

import Foundation
import EssentialFeed
// The SPY is only CAPTURING values, as we like, and it's targetting the Test.
// It doesn't have any behaviour.
// We accumulate all the properties we recieve.
class HTTPClientSpy: HTTPClient {
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()

    public var requestedURLS: [URL] {
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
        messages[index].completion(.success((data, response)))
    }
    
    // The signature of the get method are the parameters we're using here
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
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
        
        return Task()
    }
}

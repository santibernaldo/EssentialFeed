//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Santi Bernaldo on 1/3/24.
//

import XCTest
import EssentialFeed

protocol HTTPURLSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPURLSessionDataTask
}

protocol HTTPURLSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    
    let session: HTTPURLSession
    
    init(session: HTTPURLSession) {
        self.session = session
    }
    
    func load(url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, dataTask: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.load(url: url) { _ in }
        
        // ReceivedURLS is a test detail
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Any error", code: 0)
        
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load(url: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("Expected failure with \(error) got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        // ReceivedURLS is a test detail
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: HTTPURLSession {
        
        private var stubs = [URL: Stub]()
        
        struct Stub {
            let task: HTTPURLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, dataTask: HTTPURLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: dataTask, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPURLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("We couldn't find a stub with the given url \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            
            return stub.task
        }
    }
    
    // Mocking an URLSessionDataTask which carries lots of methods that we're not overriding, and these methods can be interoperating between them, so we're doing a big assumption here and risking
    
    // We don't own this classes, so this is a big risk
    private class FakeURLSessionDataTask: HTTPURLSessionDataTask {
        func resume() {
            
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPURLSessionDataTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}

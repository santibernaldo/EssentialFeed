//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Santi Bernaldo on 1/3/24.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        
        //let url = URL(string: "http://wrong.url.com")!
        
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()

    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = URL(string: "http://any-url.com")!
        
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
                
        makeSUT().get(url: url) { result in }
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "Any error", code: 0)
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
                
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(url: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                
            default:
                XCTFail("Expected failure with \(error) got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        // ReceivedURLS is a test detail
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
                
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        // It means we can handle this request, and we can control over its fate
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
}

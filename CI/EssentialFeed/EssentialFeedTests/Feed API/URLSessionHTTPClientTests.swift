//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Santi Bernaldo on 1/3/24.
//

import XCTest

class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func load(url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
    
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.load(url: url)
        
        // ReceivedURLS is a test detail
        XCTAssertEqual(session.receivedURLS, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.load(url: url)
        
        // ReceivedURLS is a test detail
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLS = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    // Mocking an URLSessionDataTask which carries lots of methods that we're not overriding, and these methods can be interoperating between them, so we're doing a big assumption here and risking
    
    // We don't own this classes, so this is a big risk
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}

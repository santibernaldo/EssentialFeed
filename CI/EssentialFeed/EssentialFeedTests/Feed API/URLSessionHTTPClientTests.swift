//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Santi Bernaldo on 1/3/24.
//

import XCTest

final class URLSessionHTTPClientTests: XCTestCase {

    func test() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSession()
        
        // ReceivedURLS is a test detail
        XCTAssertEqual(session.receivedURLS, [url])
    }

}

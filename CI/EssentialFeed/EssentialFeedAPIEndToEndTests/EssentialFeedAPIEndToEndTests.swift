//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/3/24.
//

//Comment to merge

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func demo() {
        // https://developer.apple.com/documentation/foundation/urlcache
        //  https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate/1411612-urlsession
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = cache
        
        //Every request using this URLSession will use the cache we configured
        let session = URLSession(configuration: configuration)
        
        // This would be the default URLCache. It's highly adviced to do it on the didApplicationFinishLaunching
        /*
        URLCache.shared = cache
         */
        
        let url = URL(string: "http://any-url.com")!
        // This cache policy only returns cached data, review other policies
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataDontLoad, timeoutInterval: 30.0)
    }
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
            // We assert WHY and WHEN, cause we know the index of the specified item to be asserted
            XCTAssertEqual(items[0], expectedImage(at: 0))
            XCTAssertEqual(items[1], expectedImage(at: 1))
            XCTAssertEqual(items[2], expectedImage(at: 2))
            XCTAssertEqual(items[3], expectedImage(at: 3))
            XCTAssertEqual(items[4], expectedImage(at: 4))
            XCTAssertEqual(items[5], expectedImage(at: 5))
            XCTAssertEqual(items[6], expectedImage(at: 6))
            XCTAssertEqual(items[7], expectedImage(at: 7))
            
        case let .failure(error)?:
            XCTFail("ExPected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
        
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
            let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!
            let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
            
            trackForMemoryLeaks(loader, file: file, line: line)

            let exp = expectation(description: "Wait for load completion")

            var receivedResult: FeedImageDataLoader.Result?
            _ = loader.loadImageData(from: testServerURL) { result in
                receivedResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 5.0)

            return receivedResult
        }
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> Swift.Result<[FeedImage], Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        
        var receivedResult: Swift.Result<[FeedImage], Error>?
        client.get(from: testServerURL) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try FeedItemsMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    // MARK: - Helpers
    
    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: url(at: index))
    }
    
    // Without .emepheral we would be leaving state on the disk of the saved data. We use the in-disk cache.
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func url(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
}

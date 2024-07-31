//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/7/24.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

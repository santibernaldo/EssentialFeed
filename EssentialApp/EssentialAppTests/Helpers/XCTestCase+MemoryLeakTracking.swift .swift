//
//  XCTestCase+MemoryLeakTracking.swift .swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/7/24.
//


import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

//
//  XCTestCase+MemoryLeakTracking.swift .swift
//  EssentialAppTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 31/7/24.
//

import XCTest

// Track Memory Leak: Min 17 Video 3 of the  #003 - [Image Comments UI] Reusable UI Components, Diffable Data Sources, Dynamic Type, Snapshot Testing
extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

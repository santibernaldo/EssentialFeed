//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 15/5/24.
//

import Foundation

// Ideally we would have one method per protocol to respect the INTERFACE SEGREGATION PATTERN

// Abstraction over a Core Feature of the Feed Feature module. Doesn't belong to the UI, or the Presentation module
public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}

//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 10/7/24.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    public var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}

//
//  File.swift
//  
//
//  Created by Nicolai Dam on 23/02/2023.
//

import Foundation

public struct HTTPError: Error, Equatable, LocalizedError {

    public let code: Int

    public init(code: Int) {
        self.code = code
    }
    
    public var errorDescription: String? {
        return "Http error: \(self.code.description)"
    }

}

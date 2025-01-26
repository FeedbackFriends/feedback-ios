//
//  File.swift
//  
//
//  Created by Nicolai Dam on 26/09/2021.
//

import Foundation

public struct APIError: Error, CustomNSError, Equatable, LocalizedError, Decodable {
    
    public let devInfo: String
    public let errorMessage: String
    public let route: String
    public let statusCode: Int
    
    public var errorDescription: String? {
            #if DEBUG
            return "Api error: \(self.statusCode), message \(self.errorMessage), developer info: \(self.devInfo)"
            #else
            return "Api error: \(self.statusCode), message \(self.errorMessage)"
            #endif
    }
#if !RELEASE
    public init(devInfo: String = "", errorMessage: String = "", route: String = "", statusCode: Int) {
        self.devInfo = devInfo
        self.errorMessage = errorMessage
        self.route = route
        self.statusCode = statusCode
    }
#endif
}


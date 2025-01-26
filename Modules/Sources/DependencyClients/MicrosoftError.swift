//
//  File.swift
//  
//
//  Created by Nicolai Dam on 23/02/2023.
//

import Foundation

public struct MicrosoftError: Decodable, Equatable {
    public let error: MSError
}

public struct MSError: Decodable, Equatable, Error {
    public let code: String
    public let message: String
    public let innerError: InnerError
}

public struct InnerError: Decodable, Equatable {
    public let requestId: String
    public let date: String
    public let clientRequestUd: String

    enum CodingKeys: String, CodingKey {
        case requestId = "request-id"
        case date
        case clientRequestUd = "client-request-id"
    }
}

//
//  File.swift
//  
//
//  Created by Nicolai Dam on 07/09/2023.
//

import Foundation

public struct MicrosoftEvent: Decodable, Identifiable, Hashable, Sendable {
    
    public let id: String
    public var subject: String
    public var bodyPreview: String
    public var startTime: Date
    public var endTime: Date
    public var attendees: [Attendee]
    public var location: String
    
    public init(id: String, subject: String, bodyPreview: String, startTime: Date, endTime: Date, attendees: [Attendee], location: String) {
        self.id = id
        self.subject = subject
        self.bodyPreview = bodyPreview
        self.startTime = startTime
        self.endTime = endTime
        self.attendees = attendees
        self.location = location
    }
}

public extension MicrosoftEvent {
    
    struct Attendee: Decodable, Hashable, Sendable {
        
        public var name: String
        public var email: String
        
        public init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }
}


//
//  File.swift
//  
//
//  Created by Nicolai Dam on 29/09/2023.
//

import Foundation
import Tagged

public typealias AtendeeEventID = Tagged<AttendingEvent, Int>

public struct AttendingEvent: Equatable, Decodable, Identifiable {
    
    public var id: AtendeeEventID
    public var title: String // Foredrag på himmelev skole
    public var startDate: Date // 2012-04-23T18:25:43.511Z
    public var endDate: Date // 2012-04-23T18:25:43.511Z
    public var pin: Int
    public var teamName: String
    
    public func feedbackIsGiven(savedPins: [Int]) -> Bool {
        if savedPins.contains(where: { $0 == pin }) {
            return true
        }
        return false
    }
    
    public init(id: AtendeeEventID, title: String, startDate: Date, endDate: Date, pin: Int, teamName: String) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.pin = pin
        self.teamName = teamName
    }
}

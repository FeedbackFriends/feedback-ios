//
//  File.swift
//  
//
//  Created by Nicolai Dam on 07/09/2023.
//

import Foundation

public enum InviteReply: String, Codable {
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
    case pending = "PENDING" // only relevant in teams/id
}

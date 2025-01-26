//
//  Bundle+Extension.swift
//  Feedback
//
//  Created by Nicolai Dam on 06/08/2023.
//

import Foundation

public extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
    var bundleId: String {
        return bundleIdentifier!
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

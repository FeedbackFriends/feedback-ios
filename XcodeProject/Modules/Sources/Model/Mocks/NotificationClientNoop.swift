//
//  File.swift
//  Modules
//
//  Created by Nicolai Øyen Dam on 02/05/2025.
//


extension NotificationClient {
    public static let noop = Self(
        shouldPromptForAuthorization: { _ in true },
        requestAuthorization: { true },
        scheduleLocalNotification: { _, _, _, _ , _ in },
        removeLocalPendingNotificationRequests: { _ in }
    )
}

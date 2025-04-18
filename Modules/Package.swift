// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .macOS(.v14),
        .iOS("18")
    ],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "EnterCode",
            targets: ["EnterCode"]),
        .library(
            name: "FeedbackFlow",
            targets: ["FeedbackFlow"]),
        .library(
            name: "More",
            targets: ["More"]),
        .library(
            name: "EventsFeature",
            targets: ["EventsFeature"]),
        .library(
            name: "Tabbar",
            targets: ["Tabbar"]),
        .library(
            name: "Helpers",
            targets: ["Helpers"]
        ),
        .library(
            name: "Logger",
            targets: ["Logger"]
        ),
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
        .library(
            name: "LiveClients",
            targets: ["LiveClients"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:pointfreeco/swift-snapshot-testing.git", exact: "1.18.3"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "11.3.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.4.3"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", revision: "1.17.1"),
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "1.7.0")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "1.8.0")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "1.0.2")),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                "DesignSystem",
                "Tabbar",
                "Helpers",
                "EventsFeature",
                "Logger",
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                "Helpers",
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            resources: [
                .process("Resources/Font"),
                .process("Resources/Images.xcassets"),
                .process("Resources/Lottie")
            ]),
        .target(
            name: "EnterCode",
            dependencies: [
                "DesignSystem",
                "FeedbackFlow",
                "Helpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "FeedbackFlow",
            dependencies: [
                "DesignSystem",
                "Helpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "More",
            dependencies: [
                "DesignSystem",
                "Helpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "EventsFeature",
            dependencies: [
                "DesignSystem",
                "Helpers",
                "FeedbackFlow",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "Tabbar",
            dependencies: [
                "DesignSystem",
                "EnterCode",
                "EventsFeature",
                "More",
                "Helpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "Helpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Logger",
            ]
        ),
        .target(
            name: "LiveClients",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Logger",
                "Helpers",
            ],
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "Localization"
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "AppCore",
            ]
        ),
    ]
)

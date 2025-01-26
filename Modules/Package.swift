// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .macOS(.v14),
        .iOS("17.4")
    ],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
        .library(
            name: "AdminApp",
            targets: ["AdminApp"]),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "DependencyClients",
            targets: ["DependencyClients"]),
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
            name: "LoggedInFeature",
            targets: ["LoggedInFeature"]),
        .library(
            name: "Helpers",
            targets: ["Helpers"]
        ),
        .library(
            name: "APIClient",
            targets: ["APIClient"]
        ),
        .library(
            name: "Logger",
            targets: ["Logger"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "11.3.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.4.3"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", revision: "1.17.1"),
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "1.3.1")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "1.5.0")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "AdminApp",
            dependencies: [
                "APIClient",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "HTTPTypes", package: "swift-http-types")
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "DesignSystem",
                "Logger",
                "Helpers"
            ],
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .target(
            name: "AppCore",
            dependencies: [
                "APIClient",
                "DesignSystem",
                "LoggedInFeature",
                "DependencyClients",
                "Helpers",
                "EventsFeature",
                "Logger",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
//                .product(name: "MSAL", package: "microsoft-authentication-library-for-objc"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            resources: [
                .process("Resources/Font"),
                .process("Resources/Colors.xcassets"),
                .process("Resources/Icons.xcassets"),
                .process("Lottie")
            ]),
        .target(
            name: "DependencyClients",
            dependencies: [
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Tagged", package: "swift-tagged"),
                "Helpers",
                "Logger",

            ]),
        .target(
            name: "EnterCode",
            dependencies: [
                "DesignSystem",
                "FeedbackFlow",
                "DependencyClients",
                "Helpers",
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "FeedbackFlow",
            dependencies: [
                "DependencyClients",
                "DesignSystem",
                "Helpers",
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ]),
        .target(
            name: "More",
            dependencies: [
                "DependencyClients",
                "DesignSystem",
                "Helpers",
                "APIClient",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "EventsFeature",
            dependencies: [
                "DependencyClients",
                "DesignSystem",
                "Helpers",
                "FeedbackFlow",
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "LoggedInFeature",
            dependencies: [
                "DependencyClients",
                "DesignSystem",
                "EnterCode",
                "EventsFeature",
                "More",
                "Helpers",
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "Helpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AppCore",
                "DependencyClients"
            ]
        ),
    ]
)

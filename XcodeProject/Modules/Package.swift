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
            name: "APIClient",
            targets: ["APIClient"]),
        .library(
            name: "Authentication",
            targets: ["Authentication"]),
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "EnterCodeFeature",
            targets: ["EnterCodeFeature"]),
        .library(
            name: "FeedbackFlowFeature",
            targets: ["FeedbackFlowFeature"]),
        .library(
            name: "MoreFeature",
            targets: ["MoreFeature"]),
        .library(
            name: "EventsFeature",
            targets: ["EventsFeature"]),
        .library(
            name: "TabbarFeature",
            targets: ["TabbarFeature"]),
        .library(
            name: "Logger",
            targets: ["Logger"]
        ),
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
        .library(
            name: "NotificationClient",
            targets: ["NotificationClient"]
        ),
        .library(
            name: "SystemClient",
            targets: ["SystemClient"]
        ),
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
        .library(
            name: "SignUpFeature",
            targets: ["SignUpFeature"]
        ),
        .library(
            name: "OpenAPI",
            targets: ["OpenAPI"]
        ),
        .library(
            name: "Crashlytics",
            targets: ["Crashlytics"]
        )
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            exact: "1.18.3"
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            exact: "11.3.0"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            from: "3.4.3"
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "7.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            revision: "1.17.1"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-generator",
            .upToNextMinor(from: "1.7.0")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            .upToNextMinor(from: "1.8.0")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession",
            .upToNextMinor(from: "1.0.2")
        ),
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Logger",
                "Model",
                "Utility",
                "OpenAPI",
            ],
        ),
        .target(
            name: "OpenAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                "Model",
                "Utility",
            ],
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .target(
            name: "AppCore",
            dependencies: [
                "DesignSystem",
                "TabbarFeature",
                "Model",
                "Utility",
                "EventsFeature",
                "Logger",
                "SignUpFeature",
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                "Model",
                "Utility",
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            resources: [
                .process("Resources/Fonts/Montserrat"),
                .process("Resources/Images/Images.xcassets"),
                .process("Resources/Lottie/Files")
            ]
        ),
        .target(
            name: "EnterCodeFeature",
            dependencies: [
                "DesignSystem",
                "FeedbackFlowFeature",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "FeedbackFlowFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "MoreFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "EventsFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                "FeedbackFlowFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "TabbarFeature",
            dependencies: [
                "DesignSystem",
                "EnterCodeFeature",
                "EventsFeature",
                "MoreFeature",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Logger",
                "Utility",
            ]
        ),
        .target(
            name: "Utility",
            dependencies: [
                "Logger",
            ]
        ),
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                "Logger",
                "Model",
                "Utility",
                "APIClient",
            ],
        ),
        .target(
            name: "SystemClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Model"
            ]
        ),
        .target(
            name: "NotificationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Model"
            ]
        ),
        .target(
            name: "Logger"
        ),
        .target(
            name: "Crashlytics",
            dependencies: [
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "Logger"
            ]
        ),
        .target(
            name: "Localization"
        ),
        .target(
            name: "SignUpFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DesignSystem",
                "Model",
                "Utility",
                "Logger",
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "AppCore",
                "APIClient"
            ]
        ),
    ]
)

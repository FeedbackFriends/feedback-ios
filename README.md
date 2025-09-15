# Lets Grow: Feedback iOS App

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-FA7343?logo=swift&logoColor=white&style=plastic)
![iOS 26](https://img.shields.io/badge/iOS-26-000000?logo=apple&logoColor=white&style=plastic)

This repository contains the source code for the **Lets Grow: Feedback** iOS app, available on the App Store.  
It is an open-source project built with [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) and leverages iOS 26’s new **Liquid Glass** design system.

---

## 🔧 Requirements
- Swift 6.2  
- Xcode 26  
- iOS 26  
- SwiftLint (`brew install swiftlint`)

---

## 🏗️ Architecture

The app uses a **layered architecture** that keeps business logic independent from UI and third-party SDKs.  
This approach makes the codebase **flexible, testable, and easy to maintain**.

```mermaid
---
config:
  layout: dagre
---
flowchart LR
    %% Layers
    subgraph Features[Features]
    RootFeature
    EnterCodeFeature
    EventsFeature
    FeedbackFlowFeature
    MoreFeature
    SignUpFeature
    TabbarFeature
    end

    subgraph Model
    end

    subgraph Utility
    end

    subgraph DesignSystem
    end

    subgraph Configurations
        FeedbackProd["Feedback Prod"]
        FeedbackMock["Feedback Mock"]
        Tests["Tests"]

    end

    subgraph Integrations[Integrations, SDK's]
        Implementations["Implementations"]
        OpenAPI[OpenAPI]
        Firebase[Firebase]
        GoogleSignIn["Google Sign-In"]
    end

    %% Dependency flow
    Features --> Model
    Features --> Utility
    Features --> DesignSystem

    Tests --> Features
    FeedbackMock --> Features
    FeedbackProd --> Features
    FeedbackProd --> Implementations

    Implementations --> OpenAPI
    Implementations --> Firebase
    Implementations --> GoogleSignIn

## 📦 Modularization

All code lives inside a single Swift package (`Modules`).  
Each target is a focused library with a clear responsibility:

- **Features**: `RootFeature`, `EnterCodeFeature`, `FeedbackFlowFeature`, `EventsFeature`, `MoreFeature`, `TabbarFeature`, `SignUpFeature`  
  Contain UI and feature-specific logic, built on TCA.  

- **Core**: `Domain` is represented by `Model` (data types, business logic contracts) and `Utility` / `Logger` (shared helpers).  
  Keeps the business logic independent of UI and third-party SDKs.  

- **Design**: `DesignSystem` and `Localization` centralize styling, fonts, assets, and strings for consistency across features.  

- **Integrations**: `Implementations`, `OpenAPI`, and `InfoPlist` wrap external SDKs (Firebase, Google Sign-In, OpenAPI).  
  These conform to `Domain` interfaces so features don’t import SDKs directly.  

- **Configurations**: `FeedbackProd` and `FeedbackMock` wire everything together for production or testing.  

### Benefits
- **Isolation** – each feature can evolve independently.  
- **Reusability** – modules like `DesignSystem` and `Utility` are shared across the app.  
- **Testability** – `FeedbackMock` and modular boundaries make it easy to swap real implementations for fakes.  
- **Maintainability** – changing or replacing an integration (e.g. Firebase) only affects the `Implementations` module.

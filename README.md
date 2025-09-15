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
    end

    subgraph Domain[Domain: Models, Interfaces, Business Logic]
    end

    subgraph Configurations
        FeedbackProd["Feedback Prod"]
        FeedbackMock["Feedback Mock / Tests"]
    end

    subgraph Integrations
        Implementations["Implementations (Adapters)"]
        OpenAPI[OpenAPI]
        Firebase[Firebase]
        GoogleSignIn["Google Sign-In"]
    end

    %% Dependency flow
    Features --> Domain

    FeedbackMock --> Features
    FeedbackProd --> Features
    FeedbackProd --> Implementations

    Implementations --> OpenAPI
    Implementations --> Firebase
    Implementations --> GoogleSignIn

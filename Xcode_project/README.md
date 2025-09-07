# 'Lets Grow: Feedback' iOS app 💥

[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0.0-green.svg)](https://github.com/FeedbackFriends/feedback-openapi/blob/main/openapi.yaml)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-blue.svg)](https://kotlinlang.org)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)

This repo contains the codebase for the 'Lets Grow: Feedback' iOS app, a A modern, beautiful iOS app built with SwiftUI, Composble Architecture and the latest iOS 26 SDK features.

. An app that enables you whether you're leading meetings or improving personal skills to get the feedback you need.

Available on the App Store soon!

---

## 🔧 Requirements
- Swift 6.2
- Xcode 26+
- iOS 26
- SwiftLint (`brew install swiftlint`)

---

## 🧱 Architecture

The project embraces modularization of features and layered to enforce dependency direction and isolate concerns. This leads to a flexible, testable and decoupled codebase.

``` mermaid
flowchart TD

%% --- Features (UI + State) ---
subgraph Features_UI_State["Features (UI + State)"]
    RootFeature[RootFeature]
    EventsFeature[EventsFeature]
    SignUpFeature[SignUpFeature]
    TabbarFeature[TabbarFeature]
    EnterCodeFeature[EnterCodeFeature]
    MoreFeature[MoreFeature]
    FeedbackFlowFeature[FeedbackFlowFeature]
end

%% --- Domain ---
subgraph Domain
    Model[Model]
    ServiceInterfaces[ServiceInterfaces]
end

%% --- Infrastructure ---
subgraph Infrastructure
    Implementations[Implementations]
    OpenAPI[OpenAPI]
    Mocks[Mocks]
end

%% --- Shared ---
subgraph Shared
    DesignSystem[DesignSystem]
    Utility[Utility]
    Logger[Logger]
    Localization[Localization]
    InfoPlist[InfoPlist]
end

%% --- Dependencies ---
Features_UI_State --> ServiceInterfaces
Features_UI_State --> Model
Features_UI_State --> DesignSystem

ServiceInterfaces --> Model

Implementations --> ServiceInterfaces
Implementations --> Model
OpenAPI --> Model

Mocks --> ServiceInterfaces
Mocks --> Model

Utility --> Logger
Model --> Utility
DesignSystem --> Utility
DesignSystem --> Model
```

---

## 🗂️ Module Overview

### Features
- `RootFeature`, `EventsFeature`, etc: Use `@Reducer` and TCA to manage state and effects per screen.

### Domain
- `Model`: Pure types, data structures, and business logic.
- `ServiceInterfaces`: Protocol-like interfaces (e.g. `APIClient`) annotated with `@DependencyClient`.

### Infrastructure
- `Implementations`: Concrete Firebase, Google, and OpenAPI implementations.
- `Mocks`: Test and preview versions of `ServiceInterfaces` via `TestDependencyKey`.

### Shared
- `DesignSystem`: Fonts, colors, images, animations.
- `Utility`: Small helpers (e.g. date, UUID).
- `Logger`, `Localization`, `InfoPlist`: Core configuration.

---

## 🧪 Testing Strategy

- Uses `TestDependencyKey` and `ComposableArchitecture` test helpers.
- `Mocks` module defines `previewValue` and `testValue` for all services.
- Snapshots via `swift-snapshot-testing`.

---

## ✅ Why It Works

- No feature depends on infrastructure.
- Interface-driven design: features use protocols, not implementations.
- Mocks + previews live outside production code.
- PlantUML diagrams document structure.
- SPM enables full modular build and caching.

---

## 📦 Getting Started

```bash
brew install swiftlint
open Feedback.xcodeproj
```

> Don't forget to run `swiftlint` as part of your pre-commit hook or CI pipeline.

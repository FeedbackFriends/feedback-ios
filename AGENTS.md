# Repository Guidelines

## Project Structure & Module Organization
- `Xcode_project/App/` holds the app entry point, AppDelegate, and composition root.
- `Xcode_project/Modules/Sources/` contains feature modules (TCA) plus shared layers like `Domain/`, `Adapters/`, `DesignSystem/`, `Utility/`, and `OpenAPI/`.
- `Xcode_project/Modules/Tests/` contains unit, reducer, and snapshot tests.
- `Xcode_project/Resources/` contains assets, localization, and launch assets.
- `Xcode_project/PreviewApps/` hosts focused SwiftUI preview apps.

## Build, Test, and Development Commands
- Open the project: `open Xcode_project/Feedback.xcodeproj`.
- Run locally (choose a scheme in Xcode): `Feedback Debug`, `Feedback Mock`, `Feedback Localhost`, or `Feedback Prod`.
- CLI tests (Xcode 26):
  ```bash
  xcodebuild \
    -project Xcode_project/Feedback.xcodeproj \
    -scheme "Feedback Debug" \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    test
  ```
- Linting: `swiftlint lint` (uses `Xcode_project/.swiftlint.yml`).

## Coding Style & Naming Conventions
- Swift 6.2, SwiftUI, and TCA patterns; follow Swift API Design Guidelines.
- Indentation: spaces only, Xcode default (4 spaces); no tabs.
- Types in `UpperCamelCase`, functions/properties in `lowerCamelCase`, enum cases in `lowerCamelCase`.
- SwiftLint is the source of truth: `Xcode_project/.swiftlint.yml` (line length warn 200/error 250, function body warn 200/error 300, nesting type level 3). Tests under `Xcode_project/Modules/Tests/` are excluded from linting.
- Keep reducers and dependencies scoped to their feature module; prefer `Domain` protocols with live adapters.
- When a function returning some View has any non-view statements (like let status = …) before the body, Swift can’t use the implicit return, so you must explicitly return the Button.

## Testing Guidelines
- Frameworks: XCTest, TCA `TestStore`, and `swift-snapshot-testing`.
- Place tests under `Xcode_project/Modules/Tests/` mirroring source module names.
- Name tests descriptively (e.g., `testSubmitFeedbackHappyPath`).

## Commit & Pull Request Guidelines
- Commit messages are short and imperative (e.g., `Fix ci unit tests`, `Fix keyboard on join event`).
- PRs should be focused, with a clear description and linked issue if available.
- Add tests for reducer/business logic changes; include screenshots or screen recordings for UI changes.

## Configuration & Secrets
- Runtime configuration comes from Info.plist keys (see `Docs/CONFIGURATION.md`).
- Non-mock schemes may require `GoogleService-Info.plist` for Firebase features.
- OpenAPI client code is generated during builds; avoid manual edits in `Xcode_project/Modules/Sources/OpenAPI/`.

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>swift-concurrency</name>
<description>'Expert guidance on Swift Concurrency best practices, patterns, and implementation. Use when developers mention: (1) Swift Concurrency, async/await, actors, or tasks, (2) "use Swift Concurrency" or "modern concurrency patterns", (3) migrating to Swift 6, (4) data races or thread safety issues, (5) refactoring closures to async/await, (6) @MainActor, Sendable, or actor isolation, (7) concurrent code architecture or performance optimization, (8) concurrency-related linter warnings (SwiftLint or similar; e.g. async_without_await, Sendable/actor isolation/MainActor lint).'</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>

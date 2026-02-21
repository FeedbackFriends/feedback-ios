# Lets Grow Design System Inventory

Use this file as the canonical index for reusable UI primitives in:
`Xcode_project/Modules/Sources/DesignSystem/`

## Table of Contents

1. Entry Points
2. Design Tokens
3. Reusable Views
4. Styles and Modifiers
5. Media Resources
6. Liquid Glass Patterns (iOS 26+)
7. Component Evolution Rules
8. Pre-merge Review Checklist

## 1. Entry Points

- `Xcode_project/Modules/Sources/DesignSystem/AppTheme/AppTheme.swift`
Apply global UIKit appearance (`UINavigationBar`, `UISegmentedControl`, `UIBarButtonItem`) with design-system fonts/colors.

- `Xcode_project/Modules/Sources/DesignSystem/Constants.swift`
Use `Constants.successOverlayDuration` and `Constants.maxWidthForLargeDevices`.

- `Xcode_project/Modules/Sources/DesignSystem/Resources/Colors/Colors.swift`
Use `Theme.cornerRadius`, `Theme.padding`, and all `Color.theme*`/`UIColor.theme*` extensions.

## 2. Design Tokens

### Colors

Use these tokens instead of hard-coded values:

- Mood: `themeVerySad`, `themeSad`, `themeHappy`, `themeVeryHappy`, `themeSuccess`
- Brand/action: `themeBlue`, `themePrimaryAction`, `themeOnPrimaryAction`
- Surfaces/text: `themeBackground`, `themeSurface`, `themeSurfaceSecondary`, `themeText`, `themeTextSecondary`
- Visualization/overlay: `themeGradientRed`, `themeGradientBlue`, `themeChartHighlighted`, `themeChartBackground`, `themeHoverOverlay`
- UIKit bridges: `UIColor.themeText`, `UIColor.themeBackground`

### Typography

Use Montserrat through design-system helpers:

- SwiftUI: `.font(.montserrat..., size)` from `Resources/Fonts/Font.swift`
- UIKit: `UIFont.font(.montserrat..., size)` from `Resources/Fonts/Font.swift`
- Font names in `Resources/Fonts/FontName.swift`:
`montserratBlack`, `montserratBold`, `montserratExtraBold`, `montserratExtraLight`,
`montserratItalic`, `montserratMedium`, `montserratRegular`, `montserratSemiBold`, `montserratThin`

### Domain Color Mapping

- `Xcode_project/Modules/Sources/DesignSystem/DomainColors.swift`
- Reuse `Opinion.color` and `Int.ratingColor` for opinion/rating rendering.

## 3. Reusable Views

Located in `Xcode_project/Modules/Sources/DesignSystem/ReusableViews/`:

- `Banner.swift`
Use `.banner(unwrapping:)` for offline/server error state banners.

- `EmptyStateView.swift`
Use for generic empty states with title/message.

- `ErrorView.swift`
Use for presentable error surfaces with optional retry action.

- `EventInfoView.swift`
Use for consistent event detail presentation.

- `ListItemView.swift`
Use `listElementView(image:label:foregroundColor:isLoading:)` for icon-label rows.

- `CloseView.swift`
Use `CloseButtonView(dismiss:)` for dismissal affordance.

- `UserTypePickerView.swift`
Use for role selection (`participant`/`manager`) with consistent styling.

- `SuccessOverlayView.swift`
Internal animation view used via the `successOverlay(...)` modifier.

## 4. Styles and Modifiers

### Button Styles

Located in `Xcode_project/Modules/Sources/DesignSystem/Styles/ButtonStyles/`:

- `LargeButtonStyle`
Primary CTA, capsule shape, supports loading and enabled/disabled state.

- `LargeBoxButtonStyle`
List-style large capsule rows with primary/secondary variants and loading.

- `PrimaryTextButtonStyle`
Primary textual action style for inline/toolbar use.

- `SecondaryTextButtonStyle`
Secondary textual action style.

- `ScalingButtonStyle`
Subtle pressed-state scale interaction.

- `OpacityButtonStyle`
Simple pressed-state opacity interaction.

### Other Styles

- `CustomGroupBoxStyle` in `Styles/OtherStyles/CustomGroupBoxStyle.swift`
- `sectionHeaderStyle()` in `Styles/OtherStyles/SectionHeaderStyle.swift`

### View Modifiers and Environment

- `successOverlay(message:delay:show:enableAutomaticDismissal:)`
in `ViewModifiers/SuccessOverlayModifier.swift`

- `lightShadow(color:opacity:radius:)`
in `ViewModifiers/LightShadow.swift`

- `pinCodeInputValidation(pinCodeInput:)`
in `ViewModifiers/PinCodeInputValidationModifier.swift`

- `synchronize(_:_)`
in `ViewModifiers/FocusStateSynchronize.swift`

- `isLoading(_:)` environment setter
in `EnvironmentValues/IsLoading.swift`

- `FirstResponderField` / `FirstResponderFieldView`
in `FirstResponderField.swift` for always-focused number-pad text entry.

## 5. Media Resources

### Images

Use `Image` aliases from:
`Xcode_project/Modules/Sources/DesignSystem/Resources/Images/Images.swift`

Includes brand/custom assets (`letsGrowIcon`, `letsGrowText`, smileys, social icons, handshake) and shared SF Symbols aliases.

### Lottie

- `LottieView(lottieFile:loopMode:)` in `Resources/Lottie/LottieView.swift`
- `LottieFile` options in `Resources/Lottie/LottieFile.swift`:
`fiveStars`, `messagePermission`, `loading`

## 6. Liquid Glass Patterns (iOS 26+)

Treat Liquid Glass as first-class design-system behavior.

- Prefer `.glassEffect()` for glass surfaces.
- Apply glass after layout and styling modifiers.
- Keep glass usage purposeful for interactive surfaces and overlays.
- Add fallback branches with `#available(iOS 26, *)` when needed.

Current usage examples in the codebase:

- `Xcode_project/Modules/Sources/DesignSystem/ReusableViews/Banner.swift`
- `Xcode_project/Modules/Sources/EventsFeature/WelcomeOnboardingView.swift`
- `Xcode_project/Modules/Sources/EventsFeature/DraftEventsView.swift`
- `Xcode_project/Modules/Sources/EventsFeature/ManagerEvents/CustomSection.swift`
- `Xcode_project/Modules/Sources/EventsFeature/ManagerEvents/ManagerEventsView.swift`
- `Xcode_project/Modules/Sources/FeedbackFlowFeature/Views/FeedbackElaborationTextField.swift`

## 7. Component Evolution Rules

Before adding a new primitive:

1. Search for near-match patterns in `DesignSystem` and feature modules.
2. Reuse or extend existing APIs when possible.
3. Add a new primitive only if reuse causes semantic mismatch or complexity.

When adding a new primitive:

1. Place it in the correct folder (`ReusableViews/`, `Styles/`, `ViewModifiers/`, or `Resources/`).
2. Name it with existing conventions (`...View`, `...Style`, `Color.theme...`, `Theme...`).
3. Expose minimal, defaulted API for adoption.
4. Update this inventory with purpose and file path.
5. Refactor at least one call site to demonstrate reuse.

## 8. Pre-merge Review Checklist

- No hard-coded brand colors in feature modules.
- No ad-hoc font declarations replacing Montserrat helpers.
- Buttons and loading states reuse design-system styles/environment.
- New glass effects follow iOS 26+ availability and fallbacks where required.
- New reusable primitives are documented in this file.

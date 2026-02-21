---
name: lets-grow-design-system
description: Enforce and evolve the Lets Grow iOS design system when building or refactoring SwiftUI/UIKit UI in `feedback-ios`. Use when a task touches colors, typography, spacing, reusable components, images, button styles, view modifiers, or iOS 26 Liquid Glass behavior in `Xcode_project/Modules/Sources/DesignSystem/` and feature views.
---

# Lets Grow Design System

Use this skill to keep UI implementation aligned with existing design tokens and components, and to maintain the design system as new patterns are introduced.

## Workflow

1. Inspect and reuse first
- Read `references/design-system-inventory.md`.
- Search for existing component/style usage before creating anything new:
```bash
rg -n "LargeButtonStyle|LargeBoxButtonStyle|PrimaryTextButtonStyle|theme[A-Z]|glassEffect" Xcode_project/Modules/Sources
```

2. Apply existing tokens and components
- Colors: use `Color.theme*` or `UIColor.theme*`, never hard-coded color literals.
- Typography: use `.font(.montserrat..., size)` or `UIFont.font(...)`.
- Layout: use `Theme.cornerRadius`, `Theme.padding`, `Constants.maxWidthForLargeDevices`.
- Common interactions: use `isLoading(_:)`, established `ButtonStyle`s, and reusable views/modifiers.

3. Implement Liquid Glass for iOS 26+
- Prefer `.glassEffect()` for glass surfaces.
- Apply glass last in the modifier chain after layout/styling.
- Use `#available(iOS 26, *)` when the context requires a fallback path.
- Keep interaction semantics clear: glass is visual treatment, not a substitute for accessibility or hit testing.

4. Add new design-system components only when reuse is not possible
- New reusable primitives belong in `Xcode_project/Modules/Sources/DesignSystem/`:
  - `ReusableViews/` for composable UI chunks
  - `Styles/` for button/group/text styles
  - `ViewModifiers/` for reusable behavior/styling modifiers
  - `Resources/` for tokens/assets (colors/fonts/images/lottie)
- Keep naming consistent with existing patterns (`Theme...`, `...Style`, `...View`, `Color.theme...`).
- Keep API surface minimal and defaulted for easy adoption.

5. Update the design system inventory when introducing new primitives
- Add the new component/token to `references/design-system-inventory.md`.
- Include file path and intended usage so future work reuses it instead of duplicating it.

## Guardrails

- Do not hard-code brand colors or fonts in feature modules.
- Do not duplicate a component that already exists with minor variations.
- Prefer extending existing `ButtonStyle`/modifier APIs over creating one-off styling inline.
- Keep design-system code independent from feature business logic.
- Avoid editing generated code in `Xcode_project/Modules/Sources/OpenAPI/`.

## Validation Checklist

- New/updated screens use `Color.theme*`, Montserrat fonts, and existing spacing constants.
- Buttons/loading states use design-system styles and `isLoading(_:)` where applicable.
- Glass effects are intentionally used and do not degrade non-iOS-26 behavior.
- If a new reusable component was needed, it was added in `DesignSystem` and documented in the reference file.

## References

- `references/design-system-inventory.md`: canonical tokens, components, and file locations.

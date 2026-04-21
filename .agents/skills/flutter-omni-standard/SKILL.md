---
name: flutter-omni-standard
description: Standard guidelines for Flutter development in the OmniConnect project. Use this skill whenever initiating UI tasks, creating widgets, or implementing Flutter features. It ensures visual, structural, and technical consistency by integrating prototypes, design guides, and existing patterns.
---

# Flutter OmniConnect Development Standard

This skill defines the technical and architectural standards for Flutter development within the OmniConnect project. Adherence to these guidelines is mandatory to ensure a cohesive identity, optimal performance, and maintainable code.

## Core Workflow

1.  **Contextual Research**: Before implementation, examine existing patterns in `lib/shared/widgets/` and previously implemented screens in `lib/features/`.
2.  **Focus Shift to Logic (Post-UI Baseline)**: The static UI baseline is already consolidated. Your primary responsibility now is to connect screens using **Riverpod Providers** and implement Clean Architecture's Data/Domain layers to consume the hardened Backend.
3.  **Layout Refinements**: If constructing UI, use the `flutter-building-layouts` skill. Enforce the Omni UI standard:
    - **No Bleeding**: Always respect `SafeArea`. The `AppBottomNavigationBar` and `SystemUiOverlayStyle` must create a clean edge-to-edge experience without dark native bars intersecting the app.
    - **Clean Aesthetics**: Use white backgrounds for headers (AppBars), semantic consistency, and avoid excessive `Dividers`. Use margins and spacing hierarchically.

## Identity and Styling

Refer to `documentation/design-guide.md` for the following specifications:
- **Colors**: Use defined tokens (Primary: `#1A237E`, Gold: `#DEBC74`, etc.).
- **Typography**: Utilize the `Inter` font family. Standards: H1 (24px, Bold), H2 (18px, Semi-Bold), Body (16px).
- **Spacing**: Maintain consistency using 4px or 8px increments. Prefer whitespace parsing over linear dividers.

## Architecture and Organization

- **Vertical Slicing & Layering**: We strictly follow "Full Vertical Slicing" with Clean Architecture. Every functionality is an isolated sub-feature.
- Each sub-feature has its own layers:
    - `<sub-feature>/data/`: repositories, models, data_sources.
    - `<sub-feature>/domain/`: repositories, entities, usecases.
    - `<sub-feature>/presentation/`: screens, widgets, providers.
- **Widget Placement**:
    - Global/Brand-Identity Widgets (NavBars, Base AppBars, Tokens): `lib/shared/widgets/`.
    - Feature-specific Widgets: `lib/features/<role>/<sub-feature>/presentation/widgets/`.
- **State Management**: Mandatory use of `Riverpod` for state logic. Do not pass business state purely via widget constructors.
- **Naming Conventions**: Use `snake_case` for filenames and `PascalCase` for classes.

## Reference Documentation

Consult the following documents for absolute requirements:
- `documentation/design-guide.md`: Visual identity and navigation logic.
- `documentation/architecture.md`: Section 3 acts as the ultimate truth for the Frontend structure, Data models, and API boundaries.
- `documentation/documents/*`: Technical specifications and roadmaps.

## Quality Standards

1.  **Accessibility**: Ensure touch targets are at least `48x48dp`. Maintain WCAG AA contrast ratios.
2.  **Performance**: Minimize unnecessary rebuilds. Use `const` constructors wherever possible.
3.  **Validation**: Code must pass `flutter analyze` without significant warnings.
4.  **Visual Feedback**: Implement `LoadingSkeleton` from `shared/widgets/` for all loading states.

---

*Note: This skill evolves with the project. When a better pattern is established in the codebase, prioritize the implementation in the code over the prototype or documentation.*

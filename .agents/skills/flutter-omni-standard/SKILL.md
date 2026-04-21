---
name: flutter-omni-standard
description: Standard guidelines for Flutter development in the OmniConnect project. Use this skill whenever initiating UI tasks, creating widgets, or implementing Flutter features. It ensures visual, structural, and technical consistency by integrating prototypes, design guides, and existing patterns.
---

# Flutter OmniConnect Development Standard

This skill defines the technical and architectural standards for Flutter development within the OmniConnect project. Adherence to these guidelines is mandatory to ensure a cohesive identity, optimal performance, and maintainable code.

## Core Workflow

1.  **Contextual Research**: Before implementation, examine existing patterns in `lib/shared/widgets/` and previously implemented screens in `lib/features/`.
2.  **Prototype Reference**: Use the `.pen` file in `documentation/prototype.pen` as a structural and aesthetic reference only.
    - **Note**: Prototypes may contain inconsistencies, misalignments, or AI-generated artifacts. Do not follow the prototype if it violates UI/UX best practices or established project standards.
3.  **Layout Construction**: Use the `flutter-building-layouts` skill to construct interfaces using the Flutter constraint system.
4.  **UX Refinement**: Proactively improve layouts that appear inconsistent or unintuitive. Apply harmonious spacing, correct typography, and implement feedback states (loading, error, empty).

## Identity and Styling

Refer to `documentation/design-guide.md` for the following specifications:
- **Colors**: Use defined tokens (Primary: `#1A237E`, Gold: `#DEBC74`, etc.).
- **Typography**: Utilize the `Inter` font family. Standards: H1 (24px, Bold), H2 (18px, Semi-Bold), Body (16px).
- **Spacing**: Maintain consistency using 4px or 8px increments.

## Architecture and Organization

- **Layering**: Follow the Clean Architecture pattern:
    - `data/`: Repositories and DataSources.
    - `domain/`: Entities and UseCases.
    - `presentation/`: Screens and Widgets.
- **Widget Placement**:
    - Global/Reusable Widgets: `lib/shared/widgets/`.
    - Feature-specific Widgets: `lib/features/<feature>/presentation/widgets/`.
- **Naming Conventions**: Use `snake_case` for filenames and `PascalCase` for classes.

## Reference Documentation

Consult the following documents for absolute requirements:
- `documentation/design-guide.md`: Visual identity and navigation logic.
- `documentation/documents/*`: Technical specifications and roadmaps.
- `documentation/architecture.md`: Data models and mobile structure diagrams.

## Quality Standards

1.  **Accessibility**: Ensure touch targets are at least `48x48dp`. Maintain WCAG AA contrast ratios.
2.  **Performance**: Minimize unnecessary rebuilds. Use `const` constructors wherever possible.
3.  **Validation**: Code must pass `flutter analyze` without significant warnings.
4.  **Visual Feedback**: Implement `LoadingSkeleton` from `shared/widgets/` for all loading states.

---

*Note: This skill evolves with the project. When a better pattern is established in the codebase, prioritize the implementation in the code over the prototype or documentation.*

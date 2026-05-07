# Implementation Plan: UI Inconsistencies Fix

**Branch**: `014-fix-ui-inconsistencies` | **Date**: 2026-05-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/014-fix-ui-inconsistencies/spec.md`

## Summary

This feature resolves various UI inconsistencies across the VacanSee application, focusing heavily on mobile responsiveness and professional polish. Key updates include stabilizing header tabs to prevent vertical shifting, ensuring strict grid alignment and text truncation on mobile, constraining data table widths on web with horizontal scrolling, and simplifying the admin profile permissions to a checklist. No backend or data model changes are required.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: Flutter SDK
**Storage**: N/A (UI only)
**Testing**: `flutter analyze`, manual UI verification
**Target Platform**: Flutter Web, Mobile Browser
**Project Type**: Web Application
**Performance Goals**: 60 FPS scrolling, minimal layout shifts
**Constraints**: Supabase Free Tier (no impact), Mobile-First Excellence
**Scale/Scope**: ~10 UI files affected across Admin and core screens.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Real-time Vacancy Integrity:** Pass (No impact on logic)
- **Centralized Admin Verification:** Pass (No impact on logic)
- **Performant Simplicity:** Pass (Using native Flutter widgets, avoiding over-engineering)
- **Mobile-First Excellence:** Pass (Specifically addressing mobile alignment and long text)
- **Type-Safe Sovereignty:** Pass (No `dynamic` types used)

## Project Structure

### Documentation (this feature)

```text
specs/014-fix-ui-inconsistencies/
├── plan.md              # This file
├── research.md          # UI constraints research
├── data-model.md        # Empty (no DB changes)
├── quickstart.md        # Instructions for testing UI
└── tasks.md             # To be generated
```

### Source Code (repository root)

```text
lib/
├── screens/
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── admin_profile_screen.dart (or equivalent)
│   │   └── widgets/
│   │       ├── admin_user_card.dart
│   │       ├── pending_property_card.dart
│   │       └── ...
│   └── property/
│       └── property_list_screen.dart (or equivalent tab views)
└── widgets/
    └── common/
        └── custom_tab_bar.dart (if applicable)
```

**Structure Decision**: Option 1 (Single project). Modifying existing Flutter screens and widgets within the `lib/` directory.

## Complexity Tracking

*No constitution violations. All changes align with the Performant Simplicity principle.*

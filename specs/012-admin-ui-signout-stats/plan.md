# Implementation Plan: Admin Signout and Dashboard Polish

**Branch**: `011-admin-signout-stats` | **Date**: 2026-05-07 | **Spec**: [/specs/012-admin-ui-signout-stats/spec.md](file:///c:/APPLICATIONS/vacansee/specs/012-admin-ui-signout-stats/spec.md)

## Summary
Refactor the Admin Dashboard to improve accessibility and session security. This includes a high-contrast "White Card" theme, platform-wide ecosystem statistics (Properties, Owners, Students), and a secure signout dropdown in the header.

## Technical Context
**Language/Version**: Dart 3.x (Flutter)
**Primary Dependencies**: `supabase_flutter`, `provider`
**Storage**: Supabase (PostgreSQL)
**Testing**: `flutter test` (Widget tests for Admin UI)
**Target Platform**: Web (Flutter Web)
**Project Type**: Web Application
**Performance Goals**: Load time < 1.5s
**Constraints**: Supabase Free Tier

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Real-time Vacancy Integrity**: N/A for these administrative tools, but stats will reflect current DB counts.
- **Centralized Admin Verification**: Feature targets the Admin dashboard exclusively.
- **Performant Simplicity**: Avoid heavy animations or unnecessary real-time subscriptions for stats.
- **Mobile-First Excellence**: Admin UI refactor will be tested on mobile viewport.
- **Type-Safe Sovereignty**: New `EcosystemStats` model will be fully typed.

## Project Structure

### Documentation (this feature)

```text
specs/012-admin-ui-signout-stats/
├── plan.md              # This file
├── research.md          # UI patterns and stats aggregation strategy
├── data-model.md        # EcosystemStats entity
├── quickstart.md        # Testing guide
└── tasks.md             # Implementation tasks (Next step)
```

### Source Code
```text
lib/
├── models/
│   └── admin_stats_model.dart [NEW]
├── services/
│   └── admin_service.dart [NEW]
├── providers/
│   └── admin_provider.dart [NEW]
└── screens/
    └── admin/
        ├── admin_dashboard.dart [MODIFY]
        └── widgets/
            ├── stats_card.dart [NEW]
            └── admin_profile_menu.dart [NEW]
```

## Structure Decision
Single project structure (Option 1) as this is a modular enhancement to the existing Flutter codebase.

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New AdminProvider | Separation of concerns | Adding more logic to AuthProvider would bloat the class. |

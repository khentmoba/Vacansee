# Implementation Plan: Fix Owner Property Deletion

**Branch**: `007-fix-owner-property-deletion` | **Date**: 2026-04-17 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-fix-owner-property-deletion/spec.md`

## Summary

The goal of this feature is to fix the property deletion workflow for owners. Currently, deleted properties still appear in the owner dashboard grid due to missing client-side filtering and real-time stream inclusion. We will implement a robust soft-delete mechanism that:
1. Updates property status to `deleted`.
2. Synchronizes all associated rooms to `maintenance` status for accurate vacancy tracking.
3. Implements client-side filtering in the `OwnerDashboard` and `PropertyProvider`.
4. Adds a mobile-first confirmation UX with active booking warnings and an "Undo" safety net.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: `supabase_flutter`, `provider`, `freezed`
**Storage**: Supabase (PostgreSQL)
**Testing**: `flutter test` (Unit & Widget tests)
**Target Platform**: Flutter Web (SPA)
**Project Type**: mobile-app
**Performance Goals**: < 2s UI refresh for deletion
**Constraints**: Supabase Free Tier, Mobile-First design
**Scale/Scope**: Small (Dashboard & Property Management)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Real-time Vacancy Integrity**: PASS. Room status synchronization to 'maintenance' prevents stale vacancy reports for deleted properties.
2. **Centralized Admin Verification**: PASS. Deletion preserves owner verification state.
3. **Performant Simplicity**: PASS. Leveraging existing SnackBar and Dialog patterns; filtering implemented at the provider level for efficiency.
4. **Mobile-First Excellence**: PASS. Using mobile-native confirmation patterns and success feedback.
5. **Type-Safe Sovereignty**: PASS. All updates will use `PropertyModel` and `RoomModel` via existing services.

## Project Structure

### Documentation (this feature)

```text
specs/007-fix-owner-property-deletion/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── models/             # PropertyModel, RoomModel
├── providers/          # PropertyProvider (Filtering logic)
├── services/           # ListingService (Deletion logic)
└── screens/
    └── home/           # OwnerDashboard (UI & Dialogs)
```

**Structure Decision**: Single project structure (standard Flutter).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Service Duplication | Refactoring `PropertyService` and `ListingService` | Full merge is high risk during a bug fix; localizing to `ListingService` first. |

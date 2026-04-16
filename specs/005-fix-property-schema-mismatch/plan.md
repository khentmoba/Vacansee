# Implementation Plan: fix-property-schema-mismatch

**Branch**: `003-fix-cicd-pipeline` | **Date**: 2026-04-17 | **Spec**: [spec.md](file:///c:/APPLICATIONS/vacansee/specs/005-fix-property-schema-mismatch/spec.md)
**Input**: Feature specification from `/specs/005-fix-property-schema-mismatch/spec.md`

## Summary

The goal is to resolve the `PostgrestException: Could not find the 'images' column` error and fix the property deletion logic. This will be achieved by aligning the Supabase database schema with the `PropertyModel`, removing redundant fields like `cover_image_url`, and implementing a Soft Delete mechanism to match the model's `deleted` status.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `supabase_flutter`, `freezed`  
**Storage**: Supabase (PostgreSQL)  
**Testing**: `flutter test` (Unit/Widget tests)  
**Target Platform**: Flutter Web (Mobile-first)
**Project Type**: Mobile-first Web Application  
**Performance Goals**: Real-time vacancy updates < 200ms propagation  
**Constraints**: Supabase Free Tier limits, No `dynamic` types
**Scale/Scope**: ~10k students, ~500 properties

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Alignment |
|-----------|--------|-----------|
| I. Real-time Vacancy | ✅ Pass | Schema changes preserve `.stream()` compatibility. |
| II. Centralized Admin Verification | ✅ Pass | `property_status` enum supports admin verification workflows. |
| III. Performant Simplicity | ✅ Pass | Removing redundant columns (`cover_image_url`) simplifies the data model. |
| IV. Mobile-First Excellence | ✅ Pass | Ensuring property images load correctly for students on mobile. |
| V. Type-Safe Sovereignty | ✅ Pass | Aligning DB schema with `PropertyModel` ensures end-to-end type safety without `dynamic` hacks. |

## Project Structure

### Documentation (this feature)

```text
specs/005-fix-property-schema-mismatch/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── models/
│   └── property_model.dart  # Already exists, schema must match this
├── services/
│   ├── listing_service.dart # Update delete/update logic
│   └── property_service.dart # Update create/update logic
└── screens/
    └── booking/
        └── owner_bookings_screen.dart # Verify UI handles errors gracefully

schema.sql                   # Update with migration SQL
```

**Structure Decision**: Single project (Standard Flutter structure).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Soft Delete | Auditability & Data Integrity | Hard delete would permanently lose transaction history. |
| DB Enum Type | Model Consistency | Booleans are too limited for the 3+ states defined in the model. |

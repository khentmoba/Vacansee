# Implementation Plan: Room Booking System

**Branch**: `013-room-booking-system` | **Date**: 2026-05-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/013-room-booking-system/spec.md`

## Summary
Implement a real-time booking workflow where students can request rooms, owners can approve/decline, and room availability is automatically updated. The system will leverage Supabase `pg_cron` for auto-expiration (48h) and Edge Functions with Resend for email notifications.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x)
**Primary Dependencies**: `supabase_flutter`, `flutter_riverpod`, `freezed`
**Storage**: Supabase (PostgreSQL) + `pg_cron` extension
**Testing**: `flutter test` (Unit/Widget)
**Target Platform**: Flutter Web (Mobile-first responsive)
**Project Type**: Web Application
**Performance Goals**: < 1s availability synchronization via Supabase Real-time.
**Constraints**: Supabase Free Tier ($0/month), Mobile-first UI.
**Scale/Scope**: ~10k students, ~500 properties in CDO.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Real-time Vacancy Integrity**: **PASS**. Design uses database triggers to sync `bookings` -> `rooms` and Supabase real-time for UI updates.
2. **Centralized Admin Verification**: **N/A**. Inherited from existing auth/property system.
3. **Performant Simplicity**: **PASS**. Uses server-side triggers to reduce client-side complexity and network requests.
4. **Mobile-First Excellence**: **PASS**. Implementation will use existing responsive design tokens and optimized layouts.
5. **Type-Safe Sovereignty**: **PASS**. All new models use `freezed`. Logic is strictly in `BookingService` and `BookingProvider`.
6. **0-Budget Infrastructure**: **PASS**. Uses Free Tier Supabase and Resend.

## Project Structure

### Documentation (this feature)

```text
specs/013-room-booking-system/
├── plan.md              # This file
├── research.md          # Technology decisions (pg_cron, Resend)
├── data-model.md        # Database schema and triggers
├── quickstart.md        # Setup instructions
├── contracts/           # UI and Service interface definitions
└── tasks.md             # Implementation tasks (Phase 2)
```

### Source Code (repository root)

```text
lib/
├── models/
│   ├── booking_model.dart       # Freezed model for bookings
│   └── notification_model.dart  # Freezed model for notifications
├── services/
│   ├── booking_service.dart     # Updated with approval logic
│   └── notification_service.dart # New service for alerts
├── providers/
│   ├── booking_provider.dart    # Riverpod/Provider for state
│   └── notification_provider.dart
├── screens/
│   ├── student/
│   │   └── my_bookings_screen.dart # New screen
│   └── owner/
│       └── booking_management.dart # New screen/widget
└── widgets/
    └── booking/
        └── booking_dialog.dart     # "One-tap" request UI
```

**Structure Decision**: Standard Flutter feature-based organization using the Service/Provider pattern.

## Complexity Tracking

> No violations found.

## Phase 1 Design Updates
- **Agent Context**: Updated via `update-agent-context.ps1`.
- **Contracts**: UI component contracts defined in `contracts/ui_contracts.md`.

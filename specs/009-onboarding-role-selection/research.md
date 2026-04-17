# Research: Onboarding Role Selection

## Decision: Implementation Strategy
- **Frontend Interception**: Leveraging the existing `AuthWrapper` and `AuthStatus.needsRole` logic.
- **Data Collection**: Expanding `RoleSelectionScreen` to include `displayName` and `phoneNumber` fields using a `GlobalKey<FormState>`.
- **Database Schema**: Adding `is_verified` (BOOL) to `public.users` to track owner verification status.
- **Admin Alerts**: Implementing a database-level notification system for new owner registrations using a dedicated `admin_notifications` table and a trigger/function.

## Rationale
- Using the existing `AuthStatus.needsRole` ensures that the user is blocked from accessing any other part of the app until they complete onboarding, adhering to the "Strictly Mandatory" requirement.
- Collecting name and phone number during role selection streamlines the experience and ensures contact data is available for owner verification.
- A database trigger for notifications is more reliable than frontend alerts as it guarantees the notification is created whenever a role is assigned in the database.

## Technical Context
- **Framework**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth)
- **State Management**: Provider (AuthProvider)
- **Validation**: regex-based phone number validation.

## Unknowns Resolved
- **Q**: Where to intercept? → **A**: `AuthWrapper` already does this based on `AuthStatus.needsRole`.
- **Q**: How to handle "Verified" status? → **A**: Add `is_verified` column to `public.users`, defaults to `false` for owners.
- **Q**: Admin notification? → **A**: Create `admin_notifications` table and trigger on `public.users` update where `role` becomes 'owner'.

## Alternatives Considered
- **Frontend-only role switching**: Rejected because role selection must be permanent and forced before dashboard access.
- **Bypassing phone number collection**: Rejected as phone numbers are critical for owner verification.

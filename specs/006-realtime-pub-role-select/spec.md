# Feature Specification: Real-time Publishing and Role Selection

**Feature Branch**: `006-realtime-pub-role-select`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "i want the tenant booking and owner uploading or publishing on realtime to work and also when google login is used, make it so that they can choose between registering as tenant or owner"

## Clarifications

### Session 2026-04-17

- Q: How to handle users who bypass the Role Selection screen? → A: Mandatory Block: User cannot exit or access dashboards until role is chosen.
- Q: Should a user be able to change their role later? → A: Immutable: Once a role is selected, it cannot be changed by the user.
- Q: How to handle concurrent booking requests for the last slot? → A: First-Wins: Database processes first request and pushes "Occupied" status to all clients immediately.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Role Selection during Account Creation (Priority: P1)

As a New User, I want to choose my role (Tenant or Owner) when I first sign in with Google, so that the application provides me with the correct tools and access.

**Why this priority**: Essential for user onboarding and access control. Without proper role assignment, users cannot access their respective dashboards.

**Independent Test**: Can be tested by signing in with a new Google account and verifying that a role selection screen appears before any other content.

**Acceptance Scenarios**:

1. **Given** a new user signs in via Google, **When** they complete the OAuth flow, **Then** they are presented with a choice between "Tenant" and "Owner".
2. **Given** a user has selected a role, **When** they submit their choice, **Then** their user profile in the database is updated with that role, and they are redirected to the appropriate dashboard.
3. **Given** an existing user logs in, **When** they sign in with Google, **Then** they are automatically redirected to their dashboard without being asked for a role.

---

### User Story 2 - Real-time Property Publishing (Priority: P1)

As a Property Owner, I want my newly published properties to appear instantly for students, so that I can start receiving bookings immediately without delay.

**Why this priority**: Core value proposition of "real-time" vacancy tracking.

**Independent Test**: Can be tested by having an owner publish a property while a student is on the "Explore" screen; the new property should appear without a page refresh.

**Acceptance Scenarios**:

1. **Given** an owner is on the "Add Property" screen, **When** they click "Publish", **Then** the property status becomes "verified" (or "pending" if review required) and it becomes visible to students instantly.
2. **Given** a student is viewing property listings, **When** an owner publishes a new listing, **Then** the list updates in real-time to reflect the new entry.

---

### User Story 3 - Real-time Booking Requests (Priority: P2)

As a Tenant, I want my booking requests to be delivered instantly to the owner, and I want to see updates to my booking status without refreshing.

**Why this priority**: Streamlines the interaction between tenants and owners.

**Independent Test**: Can be tested by submitting a booking as a student and verifying that the owner's dashboard updates the "Pending Bookings" count instantly.

**Acceptance Scenarios**:

1. **Given** a tenant submits a booking request, **When** the transaction completes, **Then** the owner receives a real-time notification or sees the new booking in their dashboard immediately.
2. **Given** an owner approves or rejects a booking, **When** the status changes, **Then** the tenant's "My Bookings" screen reflects the new status instantly.

---

### Edge Cases

- **Double Role Selection**: What happens if a user tries to go back after selecting a role? (Role should be immutable or require admin intervention).
- **Concurrent Bookings**: How does the system handle two real-time booking requests for the same last slot? (First request processed wins, second is notified of occupancy change).
- **Network Interruptions**: How does the system handle real-time sync failure due to lost connection? (Should show a "Reconnecting" indicator and fallback to manual refresh if sync fails).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a mandatory "Role Selection" interstitial screen for users who do not have an assigned role; users cannot exit this screen or access any dashboards until a role is selected.
- **FR-002**: System MUST persist the selected role to the `users` table in Supabase.
- **FR-003**: System MUST use Supabase Realtime (Websockets) to sync property listings across owner and tenant views.
- **FR-004**: System MUST use Supabase Realtime to push booking status updates to tenants and owners.
- **FR-005**: System MUST ensure that owners can only see their own properties and bookings in real-time, while tenants see all available listings.

### Key Entities

- **User**: Now requires a `role` attribute (`tenant`, `owner`, or `none`/`pending`).
- **Property**: Real-time stream required for `status = 'verified'`.
- **Booking**: Real-time stream required per `student_id` and `owner_id`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: New users can assign their role and reach their dashboard in under 30 seconds after Google Login.
- **SC-002**: New property listings appear on tenant devices within 2 seconds of being published by an owner.
- **SC-003**: Booking status updates are reflected on the counter-party's device within 2 seconds of the status change.
- **SC-004**: 100% of new signups result in a definitive role assignment.

## Assumptions

- **Existing Auth**: Assumes Google Login is already implemented and provide a valid Supabase Auth session.
- **Supabase Realtime**: Assumes Supabase Realtime is enabled on the `properties`, `bookings`, and `rooms` tables.
- **Mobile-First UI**: Assumes the role selection screen is responsive and mobile-friendly per project standards.

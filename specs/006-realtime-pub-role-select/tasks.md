# Tasks: Real-time Publishing and Role Selection

## Implementation Strategy
- **MVP First**: Implement US1 (Role Selection) to ensure all new users are correctly categorized.
- **Incremental Delivery**: Update providers sequentially to enable real-time streams for properties, then rooms, then bookings.

---

## Phase 1: Setup
- [ ] T001 Initialize local environment for feature `006-realtime-pub-role-select`

---

## Phase 2: Foundational
- [ ] T002 Enable Supabase Realtime for `properties`, `rooms`, and `bookings` tables in `schema.sql` (and execute in Supabase SQL Editor)
- [ ] T003 [P] Update `UserModel` to allow nullable `role` in `lib/models/user_model.dart`
- [ ] T004 [P] Update `AuthStatus` enum to include `needsRole` in `lib/providers/auth_provider.dart`

---

## Phase 3: User Story 1 - Role Selection on Login (Priority: P1)
**Goal**: Block use of app until role is selected after Google sign-in.
**Independent Test**: Sign in with a new account, verify `RoleSelectionScreen` appears and blocks access to Home until "Tenant" or "Owner" is clicked.

- [ ] T005 [US1] Update `AuthProvider.initialize()` to set status to `needsRole` if authenticated user has no role in `lib/providers/auth_provider.dart`
- [ ] T006 [US1] Implement `RoleSelectionScreen` with premium UI and "Tenant" vs "Owner" options in `lib/screens/auth/role_selection_screen.dart`
- [ ] T007 [US1] Update `AuthWrapper` in `lib/main.dart` to redirect to `RoleSelectionScreen` when `status == needsRole`
- [ ] T008 [US1] Implement `AuthProvider.setUserRole(UserRole role)` to persist selection to the database in `lib/providers/auth_provider.dart`

---

## Phase 4: User Story 2 - Real-time Property Publishing (Priority: P1)
**Goal**: New properties appear instantly on tenant devices without browser refresh.
**Independent Test**: Open two browsers, publish a property in one, see it appear in the other within 2 seconds.

- [ ] T009 [P] [US2] update `PropertyProvider.loadProperties()` to correctly manage stream subscriptions to prevent memory leaks in `lib/providers/property_provider.dart`
- [ ] T010 [US2] Add a subtle visual "New Listing" signal/pulse to items added via real-time stream in `lib/widgets/property_card.dart`

---

## Phase 5: User Story 3 - Real-time Booking Updates (Priority: P2)
**Goal**: Status changes (Approved/Rejected) reflected instantly for both parties.
**Independent Test**: Student sees booking status change to "Approved" instantly when owner updates it.

- [ ] T011 [US3] Implement `BookingProvider.subscribeToStudentBookings(String studentId)` to listen for real-time status changes in `lib/providers/booking_provider.dart`
- [ ] T012 [US3] Update owner dashboard booking counters to refresh automatically via real-time stream in `lib/providers/booking_provider.dart`
- [ ] T013 [US3] Enable real-time room occupancy updates on the property details screen in `lib/screens/student/property_details_screen.dart`

---

## Phase 6: Polish & Cross-Cutting Concerns
- [ ] T014 Run `flutter analyze` to ensure code quality
- [ ] T015 Perform manual verification of all scenarios listed in `quickstart.md`

---

## Dependencies
- **T001** (Setup) is required for all tasks.
- **Phase 2** (Foundational) is required for all User Stories.
- **Phase 3** (US1 - Role) is higher priority than US2 and US3 for data integrity.

## Parallel Execution Opportunities
- **T003**, **T004**, and **T009** can be worked on in parallel by different developers/agents as they affect independent models and providers.

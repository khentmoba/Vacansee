# Tasks: Room Booking System

**Input**: Design documents from `/specs/013-room-booking-system/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, research.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and database migrations

- [ ] T001 Update `pubspec.yaml` with any missing dependencies for notifications
- [ ] T002 Create SQL migration for `bookings` and `notifications` tables in `supabase/migrations/`
- [ ] T003 Create SQL trigger for automated room status sync in `supabase/migrations/`
- [ ] T004 Setup `pg_cron` schedule for 48-hour booking expiration in `supabase/migrations/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data models and services required by all user stories

- [ ] T005 [P] Refactor `lib/models/booking_model.dart` to use `freezed` per constitution
- [ ] T006 [P] Create `lib/models/notification_model.dart` using `freezed`
- [ ] T007 [P] Implement `lib/services/notification_service.dart` for in-app alerts
- [ ] T008 [P] Update `lib/services/booking_service.dart` with new fields and filtered queries
- [ ] T009 [P] Create `lib/providers/notification_provider.dart` for real-time notifications

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Student Booking Request (Priority: P1) 🎯 MVP

**Goal**: Allow students to submit "one-tap" booking requests with automated gender enforcement.

**Independent Test**: Student clicks "Book Now" on a room; request appears in their "My Bookings" tab; system blocks if gender mismatch.

### Implementation for User Story 1

- [ ] T010 [P] [US1] Create `lib/widgets/booking/booking_dialog.dart` for simple confirmation
- [ ] T011 [US1] Update `lib/screens/room_details.dart` to include the Booking trigger
- [ ] T012 [US1] Implement gender enforcement logic in `BookingService.createBooking`
- [ ] T013 [P] [US1] Create `lib/screens/student/my_bookings_screen.dart` to track requests
- [ ] T014 [US1] Add "My Bookings" entry to the student navigation drawer/bottom nav

**Checkpoint**: User Story 1 is functional - students can book and track status.

---

## Phase 4: User Story 2 - Owner Booking Approval (Priority: P1)

**Goal**: Allow owners to accept/decline bookings with optional notes.

**Independent Test**: Owner accepts a booking; room status updates to "Occupied" instantly; other pending requests are declined.

### Implementation for User Story 2

- [ ] T015 [P] [US2] Create `lib/screens/owner/booking_management.dart` dashboard
- [ ] T016 [US2] Implement `approveBooking` and `rejectBooking` UI in owner dashboard
- [ ] T017 [US2] Add booking request count badge to owner's home/drawer
- [ ] T018 [US2] Integrate `NotificationService` to alert owners of new requests

**Checkpoint**: User Story 2 is functional - owners can manage bookings.

---

## Phase 5: User Story 3 - Automated Room Status Update (Priority: P1)

**Goal**: Ensure room availability is perfectly synced and concurrent requests are handled.

**Independent Test**: Accepted booking triggers "Occupied" status; other students see room as unavailable.

### Implementation for User Story 3

- [ ] T019 [US3] Verify database triggers for `rooms.status` synchronization
- [ ] T020 [US3] Verify database triggers for auto-declining competing pending requests
- [ ] T021 [US3] Implement real-time listener in `ListingService` to refresh room status on-the-fly

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Notifications, background jobs, and UX refinements

- [ ] T022 [P] Setup Supabase Edge Function for Email notifications via Resend
- [ ] T023 [P] Implement push notification fallback (if applicable) or enhanced in-app popups
- [ ] T024 [P] Final UI/UX polish on booking status transitions and animations
- [ ] T025 Perform full end-to-end validation using `specs/013-room-booking-system/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (Phase 1)**: Must complete migrations before services can be tested.
- **Foundational (Phase 2)**: Refactoring `BookingModel` is critical before UI work begins.
- **User Stories (Phase 3+)**: US1 and US2 can be worked on in parallel once models are ready.

### Parallel Opportunities
- T005, T006, T007 (Models and Service) can run in parallel.
- T010, T013 (Student UI) can run in parallel with T015 (Owner UI).
- T022, T023 (Notification infrastructure) can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 & 2)
1. Complete Foundation (Phase 2).
2. Complete US1 (Booking) and US2 (Approval).
3. **STOP and VALIDATE**: Verify that a room can be booked and approved manually.

### Incremental Delivery
1. Add automated triggers (US3).
2. Add background jobs and Email polish (Phase 6).

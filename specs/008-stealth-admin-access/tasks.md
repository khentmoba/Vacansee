# Tasks: Stealth Admin Access

**Input**: Design documents from `specs/008-stealth-admin-access/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P] [Story] Description`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Database schema updates and initial structure

- [x] T001 Setup database schema updates (add 'rejected' status and 'rejection_reason' column) in schema.sql
- [x] T002 Create admin screen directory lib/screens/admin/
- [x] T003 [P] Create secret interaction wrapper placeholder in lib/widgets/common/secret_interaction_wrapper.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model and service updates that MUST be complete before user stories

- [x] T004 Update PropertyStatus enum in lib/models/property_model.dart (add 'rejected')
- [x] T005 Update PropertyModel to include rejectionReason field in lib/models/property_model.dart
- [x] T006 [P] Add isAdmin getter to AuthProvider in lib/providers/auth_provider.dart
- [x] T007 Implement moderateProperty method in lib/services/property_service.dart
- [x] T008 [P] Add property moderation helper to PropertyProvider in lib/providers/property_provider.dart

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Stealth Entry (Priority: P1) 🎯 MVP

**Goal**: Access the admin portal via a discreet 5-click sequence on the app logo.

**Independent Test**: Log in as admin, click the app title 5 times rapidly, and verify navigation to a (placeholder) admin dashboard.

### Implementation for User Story 1

- [ ] T009 [P] [US1] Complete SecretInteractionWrapper logic in lib/widgets/common/secret_interaction_wrapper.dart
- [ ] T010 [US1] Integrate SecretInteractionWrapper into HomeScreen AppBar in lib/screens/home/home_screen.dart
- [ ] T011 [US1] Create placeholder AdminDashboard screen in lib/screens/admin/admin_dashboard.dart
- [ ] T012 [US1] Implement navigation route guard for admin portal in lib/main.dart or navigation service
- [ ] T013 [US1] Add subtle visual feedback (transient glow) for registered clicks in secret_interaction_wrapper.dart

**Checkpoint**: User Story 1 (Stealth Entry) functional

---

## Phase 4: User Story 2 - Property Verification (Priority: P2)

**Goal**: Admins can verify or reject pending property listings.

**Independent Test**: As an admin, view the pending list, verify one property, and ensure it appears in student search. Reject another with a reason and ensure the reason is stored.

### Implementation for User Story 2

- [x] T014 [US2] Create PendingList widget in lib/screens/admin/widgets/pending_list.dart
- [x] T015 [US2] Implement property verification action in AdminDashboard
- [x] T016 [US2] Implement rejection dialog with mandatory reason field in lib/screens/admin/widgets/rejection_dialog.dart
- [x] T017 [US2] Ensure owner dashboard displays rejection reason for 'rejected' listings in lib/screens/home/owner_dashboard.dart
- [x] T018 [US2] Implement "Edit and Re-submit" logic (resetting status to pending on save) in lib/services/property_service.dart
- [x] T019 [US2] Implement reversibility (moving listings between statuses) in AdminDashboard

**Checkpoint**: User Story 2 (Moderation) functional

---

## Phase 5: User Story 3 - Ecosystem Stats (Priority: P3)

**Goal**: Admins see a summary of platform activity.

**Independent Test**: View the Stats tab in AdminDashboard and verify counts of students, owners, and properties match DB totals.

### Implementation for User Story 3

- [ ] T020 [US3] Create StatsView widget in lib/screens/admin/widgets/stats_view.dart
- [ ] T021 [US3] Implement user count retrieval (by role) in AuthService or a dedicated AdminService
- [ ] T022 [US3] Implement property count retrieval (by status) in PropertyService
- [ ] T023 [US3] Add Stats tab to AdminDashboard

**Checkpoint**: All user stories complete

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T024 [P] Add internal notification badge to admin portal for pending count in lib/screens/admin/admin_dashboard.dart
- [x] T020 Add loading indicators for admin actions
- [x] T021 Ensure "Secret Knock" timing is strictly enforced (500ms reset)
- [x] T022 Run final lint and static analysis
- [x] T023 Cleanup any TODOs or debug prints

**Checkpoint**: Feature complete and verified
- [ ] T027 Run quickstart.md validation for the full flow

---

## Dependencies & Execution Order

- **Phase 1 (Setup)**: Blocks Phase 2
- **Phase 2 (Foundational)**: Blocks ALL User Stories
- **Phase 3 (US1)**: Must be completed for a meaningful demo of the portal entry.
- **Phase 4 (US2)**: Core business value; depends on US1 entry point.
- **Phase 5 (US3)**: Ecosystem oversight; depends on general admin infrastructure.

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Complete Setup + Foundational
2. Complete US1 (Entry Point) → Stop and validate.

### Incremental Delivery
1. US1: Secret Knock access.
2. US2: Verify/Reject workflow.
3. US3: Stats and Dashboard Badge.

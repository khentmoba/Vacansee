# Tasks: Admin Signout and Dashboard Polish

**Input**: Design documents from `/specs/012-admin-ui-signout-stats/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Tests**: Tests are OPTIONAL. Core user journeys will be verified manually via the quickstart guide.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Create `lib/models/admin_stats_model.dart` using Freezed/JSON serializable
- [x] T002 [P] Create `lib/services/admin_service.dart` for Supabase aggregation
- [x] T003 [P] Create `lib/providers/admin_provider.dart` for state management

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T004 Implement `AdminService.getEcosystemStats` in `lib/services/admin_service.dart`
- [x] T005 Implement `AdminProvider` with stats fetching in `lib/providers/admin_provider.dart`
- [x] T006 Register `AdminProvider` in `lib/main.dart` or the appropriate provider tree

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Secure Admin Signout (Priority: P1) 🎯 MVP

**Goal**: Allow admins to securely sign out via a profile dropdown.

**Independent Test**: Click profile icon -> select Sign Out -> verify redirection to Login.

### Implementation for User Story 1

- [x] T007 [P] [US1] Create `AdminProfileMenu` widget in `lib/screens/admin/widgets/admin_profile_menu.dart`
- [x] T008 [US1] Integrate `AdminProfileMenu` into `AdminDashboard` AppBar in `lib/screens/admin/admin_dashboard.dart`

**Checkpoint**: User Story 1 functional and testable.

---

## Phase 4: User Story 2 - High-Visibility Dashboard UI (Priority: P2)

**Goal**: Refactor dashboard tabs to use a high-contrast white card theme.

**Independent Test**: Visually verify white background cards on light grey background in all tabs.

### Implementation for User Story 2

- [x] T009 [US2] Update `AdminDashboard` AppBar theme (White background, Dark text) in `lib/screens/admin/admin_dashboard.dart`
- [x] T010 [US2] Refactor `_buildPropertyQueue` to use white card theme in `lib/screens/admin/admin_dashboard.dart`
- [x] T011 [US2] Refactor `_buildOwnerQueue` to use white card theme in `lib/screens/admin/admin_dashboard.dart`

**Checkpoint**: Dashboard UI polished and meets contrast goals.

---

## Phase 5: User Story 3 - Ecosystem Statistics Overview (Priority: P2)

**Goal**: Display platform-wide statistics at the top of the dashboard.

**Independent Test**: Verify counts for Properties, Owners, and Students are displayed correctly.

### Implementation for User Story 3

- [x] T012 [P] [US3] Create `StatsCard` widget in `lib/screens/admin/widgets/stats_card.dart`
- [x] T013 [US3] Implement Stats summary section at the top of `AdminDashboard` in `lib/screens/admin/admin_dashboard.dart`
- [x] T014 [US3] Update "Ecosystem" tab to display detailed stats in `lib/screens/admin/admin_dashboard.dart`

**Checkpoint**: All user stories functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T015 Ensure all text meets AA contrast standards in `lib/screens/admin/admin_dashboard.dart`
- [x] x T016 Run `flutter analyze` to verify code quality
- [x] T017 Validate implementation against `specs/012-admin-ui-signout-stats/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies
- **Phase 1 & 2**: MUST complete first.
- **Phase 3 (US1)**: Can start after Phase 2.
- **Phase 4 & 5 (US2/US3)**: Can start after Phase 2 and proceed in parallel.

### Parallel Opportunities
- T001, T002, T003 can be done in parallel.
- T007 (US1 Profile Menu) and T012 (US3 Stats Card) can be developed in parallel.

## Implementation Strategy
1. **MVP**: Complete US1 (Signout) first to ensure session security.
2. **UI Base**: Update the AppBar and general background to establish the "White" theme.
3. **Data**: Implement Stats aggregation and display.

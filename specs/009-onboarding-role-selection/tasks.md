# Tasks: Onboarding Role Selection

**Input**: Design documents from `/specs/009-onboarding-role-selection/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/auth_logic.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Database and core model initialization

- [x] T001 Apply database schema changes (is_verified column & admin_notifications table) defined in specs/009-onboarding-role-selection/data-model.md
- [x] T002 Update UserModel factory and copyWith to include isVerified and updated fields in lib/models/user_model.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core logic updates in Services and Providers

- [x] T003 [P] Update AuthService.updateProfile to handle all profile fields (name, phone, role) in lib/services/auth_service.dart
- [x] T004 Enhance AuthProvider logic to detect missing role/phone and handle redirection state in lib/providers/auth_provider.dart

---

## Phase 3: User Story 1 - New User Role Selection (Priority: P1) 🎯 MVP

**Goal**: Mandatory collection of Role, Display Name, and Phone Number for new users.

**Independent Test**: Create a new account and verify that the onboarding form appears and persists data correctly upon submission.

### Implementation for User Story 1

- [x] T005 [P] [US1] Create regex-based phone number validation utility in lib/core/utils/validators.dart
- [x] T006 [P] [US1] Implement Form UI for Name and Phone Number in lib/screens/auth/role_selection_screen.dart
- [x] T007 [US1] Implement form validation and state management in lib/screens/auth/role_selection_screen.dart
- [x] T008 [US1] Implement `completeOnboarding` method in lib/providers/auth_provider.dart following specs/009-onboarding-role-selection/contracts/auth_logic.md
- [x] T009 [US1] Connect "Get Started" button to the new onboarding logic in lib/screens/auth/role_selection_screen.dart

---

## Phase 4: User Story 2 - Owner Verification Onboarding (Priority: P2)

**Goal**: Handle owner-specific verification state and notify admins.

**Independent Test**: Select "Owner" during onboarding and verify the `is_verified` flag is false and an entry is created in `admin_notifications`.

### Implementation for User Story 2

- [x] T010 [US2] Implement the `on_owner_registration` SQL trigger and function defined in specs/009-onboarding-role-selection/data-model.md
- [x] T011 [P] [US2] Add "Verification Pending" banner/status to the Owner Dashboard in lib/screens/home/owner_dashboard.dart
- [x] T012 [US2] Implement conditional "Create Property" button state based on `isVerified` in lib/screens/home/owner_dashboard.dart

---

## Phase 5: User Story 3 - Persistence of Role (Priority: P1)

**Goal**: Ensure smooth redirection for returning users.

**Independent Test**: Log out and log back in; verify direct dashboard access for existing users.

### Implementation for User Story 3

- [x] T013 [P] [US3] Verify `AuthWrapper` routing logic for `AuthStatus.authenticated` vs `AuthStatus.needsRole` in lib/main.dart
- [x] T014 [US3] Add login-time check for missing profile details in `AuthProvider.initialize`

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Visual refinements and final validation

- [x] T015 [P] Add premium micro-animations (e.g., card scaling, smooth transitions) to lib/screens/auth/role_selection_screen.dart
- [x] T016 Run Full Verification flow as documented in specs/009-onboarding-role-selection/quickstart.md
- [x] T017 [P] Perform `flutter analyze` and fix any linting issues across modified files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Base schema must be updated before code can interact with new columns.
- **Foundational (Phase 2)**: Service and Model updates must be complete before UI can use them.
- **User Stories (Phase 3+)**: All depend on Foundational logic. US1 is the highest priority MVP.

### Parallel Opportunities

- T003 (Service) and T004 (Provider) can be worked on concurrently.
- T005 (Validators) and T006 (UI Layout) can be worked on concurrently.
- Polish tasks (T015, T017) can be done independently after core functionality is verified.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 & 2 (Schema & Service Foundation).
2. Complete Phase 3 (Role & Profile form).
3. **VALIDATE**: Ensure a new user can successfully become a "Student" and reach the dashboard.

### Incremental Delivery

1. Deploy US1 (Core selection).
2. Deploy US2 (Owner verification gate).
3. Deploy US3 (Persistence refinements).

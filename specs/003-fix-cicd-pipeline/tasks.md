# Tasks: Fix CI/CD Pipeline

**Input**: Design documents from `/specs/003-fix-cicd-pipeline/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Fix repository structural issues blocking git operations.

- [ ] T001 Remove nested git repository metadata in `c:/APPLICATIONS/vacansee/Vacansee/.git` to restore main repo tracking

---

## Phase 2: Foundational (Blocking Compilation Fixes)

**Purpose**: Fix blocking compiler errors that prevent any build/deployment.

**⚠️ CRITICAL**: No user story work can begin until the code actually compiles.

- [ ] T002 Fix `undefined_named_parameter: coverImageUrl` in `lib/providers/property_provider.dart:259`
- [ ] T003 Fix `undefined_named_parameter: coverImageUrl` in `lib/providers/property_provider.dart:301`
- [ ] T004 [P] Make `_lastVacancyUpdate` final in `lib/providers/property_provider.dart:23`

**Checkpoint**: Code foundation compiles - user story implementation can now begin.

---

## Phase 3: User Story 1 - Restore Automated Deployment (Priority: P1) 🎯 MVP

**Goal**: Pass all `flutter analyze` gates to enable the Vercel deployment pipeline.

**Independent Test**: Run `flutter analyze` locally and ensure it returns exit code 0.

### Implementation for User Story 1

- [ ] T005 [P] [US1] Resolve async context violations in `lib/screens/booking/owner_bookings_screen.dart`
- [ ] T006 [P] [US1] Resolve async context violations in `lib/screens/home/owner_dashboard.dart`
- [ ] T007 [P] [US1] Resolve async context violations in `lib/screens/profile/profile_screen.dart`
- [ ] T008 [P] [US1] Resolve async context violations in `lib/screens/property/create_property_screen.dart`
- [ ] T009 [P] [US1] Fix `deprecated_member_use: withOpacity` in `lib/screens/auth/email_verification_screen.dart`

**Checkpoint**: At this point, CI analysis gate should pass perfectly.

---

## Phase 4: User Story 2 - Clean Git Repository State (Priority: P2)

**Goal**: Ensure the repository is in a clean state for automated synchronization.

**Independent Test**: `git status` should show all `Vacansee/` contents as staged but not as "untracked content" of a subrepo.

### Implementation for User Story 2

- [ ] T010 [US2] Stage all previously untracked files from the restored `Vacansee/` directory
- [ ] T011 [US2] Commit and push the `003-fix-cicd-pipeline` branch to verify GitHub Action triggers

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification of the deployment pipeline.

- [ ] T012 Monitor [GitHub Actions](https://github.com/khentmoba/Vacansee/actions) for successful Vercel deployment
- [ ] T013 Verify the generated Vercel Preview URL and site functionality

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Must complete first to ensure git commands work.
- **Foundational (Phase 2)**: Fixes blocking compiler errors.
- **User Story 1 (Phase 3)**: Resolves linting issues required for CI gate.
- **User Story 2 (Phase 4)**: Finalizes the repository state.

### Parallel Opportunities

- Tasks T004, T005, T006, T007, T008, T009 can all be worked on in parallel as they affect different files and have no inter-dependencies once T002/T003 are resolved.

---

## Implementation Strategy

### MVP First (CI Restoration)

1. Complete Phase 1: Setup (Git Clean)
2. Complete Phase 2: Foundational (Compilation Fix)
3. Complete Phase 3: US1 (Analysis Pass)
4. **STOP and VALIDATE**: Test `flutter analyze` locally
5. Push and trigger CI

### Parallel Example: User Story 1

```bash
# Fix all screens in parallel:
Task: "Resolve async context violations in lib/screens/booking/owner_bookings_screen.dart"
Task: "Resolve async context violations in lib/screens/home/owner_dashboard.dart"
Task: "Resolve async context violations in lib/screens/profile/profile_screen.dart"
```

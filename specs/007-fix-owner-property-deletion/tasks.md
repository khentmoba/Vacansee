# Tasks: Fix Owner Property Deletion

**Input**: Design documents from `/specs/007-fix-owner-property-deletion/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Basic service and provider alignment

- [ ] T001 [P] Ensure `ListingService` is properly injected or accessible in `PropertyProvider` at `lib/providers/property_provider.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core backend logic and data integrity rules

- [ ] T002 Implement `hasActiveBookings(propertyId)` query in `lib/services/listing_service.dart`
- [ ] T003 Update `deletePropertyListing(propertyId)` to include bulk room status sync to 'maintenance' in `lib/services/listing_service.dart`
- [ ] T004 Implement `restorePropertyListing(propertyId)` to revert status to 'verified' in `lib/services/listing_service.dart`

**Checkpoint**: Foundation ready - UI implementation can now begin

---

## Phase 3: User Story 1 - Permanent Deletion (Priority: P1) 🎯 MVP

**Goal**: Owners can delete properties and see them removed from the dashboard

**Independent Test**: Delete a listing from Owner Dashboard and verify it disappears from the grid and stats immediately.

### Implementation for User Story 1

- [ ] T005 [US1] Update `PropertyProvider.deleteProperty` to utilize `ListingService.deletePropertyListing` at `lib/providers/property_provider.dart`
- [ ] T006 [US1] Implement filtering for `status == 'deleted'` in the `PropertyProvider.properties` getter or `loadOwnerProperties` at `lib/providers/property_provider.dart`
- [ ] T007 [US1] Refactor `_buildPropertyCard` delete action to use the provider's `deleteProperty` method at `lib/screens/home/owner_dashboard.dart`
- [ ] T008 [US1] Integrate `hasActiveBookings` check into the deletion workflow in `OwnerDashboard` and show warning text if bookings found at `lib/screens/home/owner_dashboard.dart`

**Checkpoint**: User Story 1 functional - basic deletion and filtering enabled.

---

## Phase 4: User Story 2 - Error Handling & Undo (Priority: P2)

**Goal**: Provide feedback and a safety net for accidental deletions

**Independent Test**: Delete a property, click "Undo" on the SnackBar, and verify the property reappears.

### Implementation for User Story 2

- [ ] T009 [US2] Wrap the deletion call in `OwnerDashboard` with a try-catch block and show an Error SnackBar at `lib/screens/home/owner_dashboard.dart`
- [ ] T010 [US2] Implement `restoreProperty(propertyId)` in `PropertyProvider` to handle the Undo action at `lib/providers/property_provider.dart`
- [ ] T011 [US2] Add the "Undo" action to the success SnackBar calling `restoreProperty` at `lib/screens/home/owner_dashboard.dart`

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and code quality

- [ ] T012 [P] Verify storage cleanup is non-blocking in `ListingService.deletePropertyListing`
- [ ] T013 Run `flutter analyze` to ensure no linting regressions
- [ ] T014 Perform final manual validation using [quickstart.md](quickstart.md)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on T001. BLOCKS User Story 1.
- **User Story 1 (Phase 3)**: Depends on Phase 2. Must be verified before Phase 4.
- **User Story 2 (Phase 4)**: Depends on US1 completion (deletion trigger exists).
- **Polish (Phase 5)**: Final verification.

### Parallel Opportunities

- T001 and foundational tasks can be started together.
- Once Foundational logic is done (T002-T004), UI tasks (T005-T008) can proceed.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Setup and Foundational logic.
2. Implement US1 filtering and basic deletion in the Dashboard.
3. Validate that listings disappear from the UI after deletion.

### Incremental Delivery

1. Foundation ready (T002-T004).
2. UI Deletion (T005-T008).
3. Feedback & Undo (T009-T011).

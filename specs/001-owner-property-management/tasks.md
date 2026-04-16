# Tasks: Owner Property Management

**Input**: Design documents from `specs/001-owner-property-management/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/listing_management.md

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 [P] Configure RLS policies for `properties` and `rooms` tables in Supabase SQL Editor per `data-model.md`
- [x] T002 Update `pubspec.yaml` with `freezed` and `json_annotation` if missing

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T003 [P] Update `Property` and `Room` models in `lib/models/` to support JSON serialization and pre-population
- [x] T004 [P] Implement `ListingService` stub in `lib/services/listing_service.dart` following `contracts/listing_management.md`
- [x] T005 [P] Create `ConfirmationDialog` widget in `lib/widgets/common/confirmation_dialog.dart` for deletion safety

## Phase 3: User Story 1 - Edit Property Listing (Priority: P1) 🎯 MVP

**Goal**: Owners can edit listing details, rooms, and images with real-time updates and address-change re-verification.

- [x] T006 [US1] Implement address-change re-verification logic in `ListingService.updatePropertyListing`
- [x] T007 [US1] Build `EditPropertyScreen` UI in `lib/screens/owner/edit_property_screen.dart` with pre-filled `Form`
- [x] T008 [US1] Implement granular Room management (Add/Update/Remove) in `EditPropertyScreen`
- [x] T009 [US1] Implement granular Image management (Delete current/Add new) in `EditPropertyScreen`
- [x] T010 [US1] Add "Edit" action to `OwnerDashboard` in `lib/screens/owner/owner_dashboard.dart`
- [x] T011 [US1] Connect `EditPropertyScreen` to `ListingService` and handle dashboard redirection

## Phase 4: User Story 2 - Delete Property Listing (Priority: P2)

**Goal**: Owners can delete properties with full asset cleanup (Storage and DB).

- [x] T012 [US2] Implement deletion logic and Storage batch-purge in `ListingService.deletePropertyListing`
- [x] T013 [US2] Integrate `ConfirmationDialog` with "Delete" action in `OwnerDashboard`
- [x] T014 [US2] Add success snackbar and dashboard refresh logic upon deletion

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T015 [P] Add loading indicators and error handling to all management actions
- [x] T016 Run `flutter analyze` and verify all real-time broadcasts on the student view
- [x] T017 Verify `quickstart.md` manual test scenarios

## Dependencies & Execution Order

- **Foundational (Phase 2)**: MUST complete T003 and T004 before UI work (T007-T014).
- **User Story 1 (P1)**: Independent of US2, but requires `ListingService` stubs.
- **User Story 2 (P2)**: Requires `ConfirmationDialog` (T005) and `ListingService`.

# Tasks: fix-property-schema-mismatch

**Input**: Design documents from `/specs/005-fix-property-schema-mismatch/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and validation

- [ ] T001 Review `lib/models/property_model.dart` and `schema.sql` for consistency
- [ ] T002 [P] Prepare Supabase migration script based on `quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core database infrastructure updates

**⚠️ CRITICAL**: No user story work can begin until the database schema is aligned.

- [ ] T003 Update `schema.sql` to include `property_status` enum and `images` column in `properties` table
- [ ] T004 Apply schema changes to Supabase (Add `images`, Add `status`, Drop `is_verified`, Drop `cover_image_url`)
- [ ] T005 Update Supabase RLS policies in `schema.sql` to filter by `status = 'verified'` and allow owners to see `deleted` properties

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Create Property with Images (Priority: P1) 🎯 MVP

**Goal**: Enable owners to create properties with multiple images without schema errors.

**Independent Test**: Successfully save a property with 3+ images and verify they appear in the dashboard.

### Implementation for User Story 1

- [ ] T006 [P] [US1] Update `PropertyService.createProperty` in `lib/services/property_service.dart` to include `images` and handle `property_status`
- [ ] T007 [P] [US1] Update `PropertyService.updateProperty` in `lib/services/property_service.dart` to reset `status` to `pending` on address change
- [ ] T008 [US1] Verify property creation and image rendering in `lib/screens/booking/owner_bookings_screen.dart`

**Checkpoint**: User Story 1 (Creation) functional and testable.

---

## Phase 4: User Story 2 - Delete Property Listing (Priority: P1)

**Goal**: Implement soft delete and resilient storage cleanup.

**Independent Test**: Delete a property, verify it stays in DB as `deleted` but disappears from the public UI.

### Implementation for User Story 2

- [ ] T009 [P] [US2] Update `ListingService.deletePropertyListing` in `lib/services/listing_service.dart` to use `status = 'deleted'` (Soft Delete)
- [ ] T010 [P] [US2] Implement non-blocking `try-catch` for storage cleanup in `lib/services/listing_service.dart`
- [ ] T011 [US2] Update `PropertyService.deleteProperty` in `lib/services/property_service.dart` to call `ListingService.deletePropertyListing` (or ensure consistency)
- [ ] T012 [US2] Verify soft delete and storage cleanup logs in the console

**Checkpoint**: User Story 2 (Deletion) functional and testable.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Quality assurance and code hygiene

- [ ] T013 [P] Remove any legacy `cover_image_url` references in UI widgets (search for `coverImageUrl` getter usage)
- [ ] T014 Run `flutter analyze` to ensure zero lint errors
- [ ] T015 Perform final verification using `quickstart.md` scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all story implementation.
- **User Stories (Phase 3-4)**: Depend on Foundational completion.
- **Polish (Phase 5)**: Depends on all stories completion.

### Parallel Opportunities

- T002, T006, T007, T009, T010, T013 can run in parallel (different files/concerns).
- Once Phase 2 is done, US1 and US2 implementation can technically run in parallel, though US1 is the primary MVP.

---

## Parallel Example: Services Update

```bash
# Update both services in parallel:
Task: "Update PropertyService in lib/services/property_service.dart"
Task: "Update ListingService in lib/services/listing_service.dart"
```

---

## Implementation Strategy

### MVP First (US1)
1. Foundational DB updates.
2. US1 Implementation (Creation).
3. Validate US1.

### Incremental Delivery
1. Add US2 (Deletion) after US1 is stable.
2. Polish UI/Cleanup.

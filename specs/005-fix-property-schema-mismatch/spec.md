# Feature Specification: fix-schema-and-model-mismatches

**Feature Branch**: `005-fix-property-schema-mismatch`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "i want you to fix this error and also the delete is still not working but i believe its connected to this error"

## Clarifications

### Session 2026-04-17
- Q: Should we expand the scope to include the `bookings` table error (`student_name` missing)? → A: **Yes**, include both fixes.
- Q: Should we standardize the database to use the `status` enum instead of the `is_verified` boolean? → A: **Yes**, replace all `is_verified` logic with `status = 'verified'`.
- Q: Should property deletion be a Soft Delete or a Hard Delete? → A: **Soft Delete** (set `status = 'deleted'`).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Property with Images (Priority: P1)
As a Property Owner, I want to create a new property listing with multiple images, so that students can see what the boarding house looks like.
**Acceptance Scenarios**:
1. **Given** the owner provides images, **When** they save, **Then** the property record is created with an `images` array in Supabase.
2. **Given** a property is fetched, **When** checking the model, **Then** `images` is a populated `List<String>`.

### User Story 2 - Request a Room Booking (Priority: P1)
As a Student, I want to book a room, so that I can secure my accommodation for the semester.
**Acceptance Scenarios**:
1. **Given** a student is logged in, **When** they click 'Book Now', **Then** the booking record is created in Supabase with their `student_name` and `student_email` correctly populated.
2. **Given** a booking request, **When** it is saved to the DB, **Then** no `not-null constraint` violation occurs for `student_name`.

### User Story 3 - Delete Property Listing (Priority: P1)
As a Property Owner, I want to remove my property listing when it's no longer available.
**Acceptance Scenarios**:
1. **Given** a property exists, **When** the owner deletes it, **Then** the property `status` is changed to `deleted` (Soft Delete).
2. **Given** a property is soft-deleted, **When** as a student I search for properties, **Then** I cannot see the deleted listing.
3. **Given** a property is soft-deleted, **When** as an owner I check my dashboard, **Then** associated images are removed from storage to save space.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST add an `images` column of type `TEXT[]` to the `properties` table.
- **FR-002**: System MUST replace all `is_verified` boolean logic in RLS policies and views with `status = 'verified'` checks.
- **FR-003**: System MUST update `BookingModel.toJson()` to include `student_name`, `student_email`, and `student_phone`.
- **FR-004**: System MUST implement "Soft Delete" logic for properties by updating status to `deleted`.
- **FR-005**: System MUST ensure `PropertyService` and `BookingService` handle required fields correctly during insertions.

### Key Entities
- **Property**: `id`, `owner_id`, `name`, `address`, `status` (enum), `images` (List<String>).
- **Booking**: `id`, `student_id`, `property_id`, `room_id`, `student_name`, `student_email`, `status` (enum).

## Success Criteria *(mandatory)*
- **SC-001**: 100% of property creation attempts succeed with image arrays.
- **SC-002**: 100% of booking requests succeed without `student_name` null constraint errors.
- **SC-003**: All RLS policies and views use the `status` enum consistently.
- **SC-004**: Database schema `schema.sql` reflects these changes.

## Assumptions
- **DB Migration**: The user will run the provided SQL snippet in the Supabase SQL Editor.
- **Cascade Deletes**: Soft deletion of a property does not necessarily trigger CASCADE deletes of rooms (it leaves them orphaned but hidden via property status).

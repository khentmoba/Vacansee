# Feature Specification: fix-property-schema-mismatch

**Feature Branch**: `005-fix-property-schema-mismatch`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "i want you to fix this error and also the delete is still not working but i believe its connected to this error"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Property with Images (Priority: P1)

As a Property Owner, I want to create a new property listing with multiple images, so that students can see what the boarding house looks like.

**Why this priority**: Core functionality that is currently broken due to a schema mismatch (`PostgrestException: Could not find the 'images' column`).

**Independent Test**: Can be tested by filling out the 'Add Property' form, selecting images, and clicking 'Save'. Success is indicated by the property being created in Supabase and visible in the dashboard.

**Acceptance Scenarios**:

1. **Given** the owner is on the 'Add Property' screen, **When** they fill the details and provide images, **Then** the property is saved successfully without a `PostgrestException`.
2. **Given** a property is created, **When** it's fetched back from the database, **Then** the `images` list contains the uploaded URLs.

---

### User Story 2 - Delete Property Listing (Priority: P1)

As a Property Owner, I want to delete my property listing when it's no longer available, so that it's removed from the search results and associated storage is cleaned up.

**Why this priority**: Critical functionality that is currently failing. The deletion process relies on selecting an `images` column that doesn't exist.

**Independent Test**: Can be tested by clicking the 'Delete' button on an existing property and confirming. Success is indicated by the property disappearing from the database and the dashboard.

**Acceptance Scenarios**:

1. **Given** a property exists, **When** the owner deletes it, **Then** the database record is removed and no "column not found" error occurs.
2. **Given** a property has associated images in storage, **When** the property is deleted, **Then** those images are also removed from Supabase Storage.

---

### Edge Cases

- **Missing Images**: What happens when a property is created without any images? (Should default to empty array `{}` in Postgres).
- **Broken Image URLs**: How does the system handle deleting a property if its storage images are already missing? (Should log error and continue deleting DB record).
- **Concurrent Deletion**: How does the system handle if multiple deletion attempts occur? (Postgres should handle with 404/no-op).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST add an `images` column of type `TEXT[]` to the `properties` table in Supabase.
- **FR-002**: System MUST ensure the `PropertyModel` `status` enum maps correctly to the database `is_verified` boolean or update the schema to use an enum.
- **FR-003**: System MUST update `ListingService.deletePropertyListing` to handle the `images` data correctly without triggering "column not found" errors.
- **FR-004**: System MUST remove the `cover_image_url` field if it's redundant with the `images` list, or ensure they are synchronized.
- **FR-005**: System MUST ensure `PropertyService` ignores UI-only fields like `has_vacancy` during database operations.

### Key Entities *(include if feature involves data)*

- **Property**: Represents a boarding house. Key attributes: `id`, `name`, `address`, `images` (list of URLs), `status`.
- **Room**: Represents a specific room in a property. Linked to `Property` via `property_id`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of property creation attempts with images succeed (zero `PostgrestException` for missing columns).
- **SC-002**: 100% of property deletion attempts succeed.
- **SC-003**: All associated image files in `property_images` storage bucket are successfully deleted when a property is removed.
- **SC-004**: Database schema `schema.sql` is fully synchronized with the `PropertyModel` definition.

## Assumptions

- **Database Update**: Assumes the user has the ability to run the provided SQL in the Supabase SQL Editor or that I should provide a clear SQL snippet for them to execute.
- **Storage Bucket**: Assumes the `property_images` bucket exists and is correctly configured (referencing `schema.sql` line 182).
- **Cascade Deletes**: Assumes `ON DELETE CASCADE` is properly set up for `rooms` and `bookings` (confirmed in `schema.sql` lines 43 and 57).

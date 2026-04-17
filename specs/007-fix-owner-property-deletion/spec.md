# Feature Specification: Fix Owner Property Deletion

**Feature Branch**: `fix-owner-delete-property-listing`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "the owner still cant delete in owner dashboard"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Permanent Deletion of Listings (Priority: P1)

As a property owner, I want to delete my boarding house listings so that they are no longer visible in my dashboard and students cannot book them.

**Why this priority**: Core functionality that is currently broken or misleading. Owners need to be able to remove properties they no longer manage.

**Independent Test**: Can be tested by clicking "Delete" on a property card in the Owner Dashboard, confirming the dialog, and verifying the property disappears from the grid and stats.

**Acceptance Scenarios**:

1. **Given** an owner has active or pending listings, **When** they click Delete and confirm, **Then** the listing should immediately disappear from the Owner Dashboard grid.
2. **Given** an owner has deleted a listing, **When** the dashboard refreshes, **Then** the deleted listing should not reappear.
3. **Given** a listing is deleted, **When** checking the dashboard stats, **Then** the "Total Listings" count should decrease accordingly.

---

### User Story 2 - Error Handling and Feedback (Priority: P2)

As a property owner, I want to see clear feedback if a deletion fails so that I know the status of my request.

**Why this priority**: Improves UX and helps diagnose issues if deletion fails due to technical errors.

**Independent Test**: Can be tested by mocking a network failure during deletion and verifying an error SnackBar appears.

**Acceptance Scenarios**:

1. **Given** a network error occurs during deletion, **When** the owner confirms deletion, **Then** an error message should be displayed and the item should remain in the grid.

---

### Edge Cases

- **What happens when a property has active bookings?**: The system should allow deletion (soft delete preserves records for historical reference) but might need to warn the owner. *Assumption: Soft delete is preferred to preserve booking history.*
- **How does system handle storage cleanup?**: Associated images in Supabase Storage should be removed to save space, but failure to clean storage should not block the status update.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST filter out properties with `status = 'deleted'` from the Owner Dashboard grid view.
- **FR-002**: System MUST catch and handle errors during the deletion process in the `OwnerDashboard` UI.
- **FR-003**: System MUST update the `PropertyProvider` state or trigger a refresh that excludes deleted properties.
- **FR-004**: System MUST ensure that `ListingService.deletePropertyListing` correctly updates the status and handles associated room images.
- **FR-005**: System MUST provide a success/failure SnackBar feedback to the user after the deletion attempt.

### Key Entities

- **Property**: Represented by `PropertyModel`. Has a `status` field which can be `pending`, `verified`, or `deleted`.
- **ListingService**: Handles the complex logic of updating the property status and cleaning up associated storage assets (images).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Owners can delete a property and see it removed from their dashboard in under 2 seconds (excluding network latency).
- **SC-002**: 100% of successfully deleted properties (status set to 'deleted') are hidden from the owner's dashboard view.
- **SC-003**: 100% of failed deletion attempts show a user-friendly error message.

## Assumptions

- **Soft Delete Pattern**: We use a soft delete pattern (`status = 'deleted'`) rather than a hard SQL `DELETE` to maintain data integrity for existing bookings and audit trails.
- **Filtered Streams**: The Supabase `.stream()` used in `PropertyService.getOwnerProperties` does not support complex `WHERE` clauses for exclusion as easily as for inclusion, so client-side filtering or a more specific stream query is needed.
- **Mobile-First UX**: The deletion confirmation and feedback must be easily actionable on mobile devices.
- **Storage Cleanup**: Storage cleanup is non-blocking to ensure the primary state change (status update) is perceived as successful.

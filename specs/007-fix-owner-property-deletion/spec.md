# Feature Specification: Fix Owner Property Deletion

**Feature Branch**: `007-fix-owner-property-deletion`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "the owner still cant delete in owner dashboard"

## Clarifications

### Session 2026-04-17
- Q: Handling active bookings during deletion → A: **Warning**: Allow deletion but show a specific warning if active bookings exist.
- Q: Room status synchronization → A: **Yes**: Update all room statuses to 'maintenance' when property is deleted to ensure they are excluded from vacancy counts.
- Q: Storage cleanup blocking → A: **Non-blocking**: Deletion succeeds even if image cleanup in storage fails.
- Q: Admin hard-delete → A: **Out of Scope**: This feature focuses only on the owner dashboard soft-delete.
- Q: Success feedback pattern → A: **SnackBar with "Undo"**: Provide immediate feedback with a short window to revert the soft-delete.

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

- **What happens when a property has active bookings?**: The system allows deletion (soft delete) but MUST show a warning dialog if any bookings have status 'pending' or 'approved'.
- **How does system handle storage cleanup?**: Associated images in Supabase Storage are removed. This process is non-blocking; if it fails, the property status change still proceeds.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST filter out properties with `status = 'deleted'` from the Owner Dashboard grid view.
- **FR-002**: System MUST catch and handle errors during the deletion process and display them to the user.
- **FR-003**: System MUST update all associated rooms to `status = 'maintenance'` when the parent property is deleted.
- **FR-004**: System MUST verify if active bookings exist before showing the final deletion confirmation.
- **FR-005**: System MUST provide a "Restore" (Undo) option in the success SnackBar for a limited time (e.g., 5 seconds).
- **FR-006**: System MUST ensure storage cleanup is attempted but does not block the database status update.

### Key Entities

- **Property**: Represented by `PropertyModel`. Has a `status` field which can be `pending`, `verified`, or `deleted`.
- **ListingService**: Handles the complex logic of updating the property status and cleaning up associated storage assets (images).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Owners can delete a property and see it removed from their dashboard grid in under 2 seconds.
- **SC-002**: 100% of "deleted" properties are excluded from student-side search results and maps.
- **SC-003**: "Deleted" listings contribute 0 value to the "Available Rooms" count in the Owner Dashboard.
- **SC-004**: Users are able to restore a mistakenly deleted property via the Undo SnackBar.

## Assumptions

- **Soft Delete Pattern**: We use a soft delete pattern (`status = 'deleted'`) rather than a hard SQL `DELETE` to maintain data integrity for existing bookings and audit trails.
- **Filtered Streams**: The Supabase `.stream()` used in `PropertyService.getOwnerProperties` does not support complex `WHERE` clauses for exclusion as easily as for inclusion, so client-side filtering or a more specific stream query is needed.
- **Mobile-First UX**: The deletion confirmation and feedback must be easily actionable on mobile devices.
- **Storage Cleanup**: Storage cleanup is non-blocking to ensure the primary state change (status update) is perceived as successful.

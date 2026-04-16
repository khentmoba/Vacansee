# Feature Specification: Owner Property Management

**Feature Branch**: `001-owner-property-management`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "in the owner dashboard, i want the owner to be able to edit their added property or listing as well as delete it, basically have full control over it"

## Clarifications

### Session 2026-04-17
- Q: When a property is deleted, should the system also purge associated room records and images? → A: Purge All (Delete property, rooms, and storage images).
- Q: Where should the owner be navigated to upon successful "Save" or "Delete Confirmation"? → A: Home Redirect (Back to OwnerDashboard with a snackbar/toast success message).
- Q: What degree of control should the owner have over individual room entries during edit? → A: Full Lifecycle (Owner can add new rooms, update existing ones, and delete specific rooms).
- Q: How should the system handle existing property images during edit? → A: Granular Image Management (Owner can delete individual images and upload new ones).
- Q: If a property owner updates the primary address of a verified listing, how should the system handle the status? → A: Re-verification (Reset status to "Pending Verification" if address changes).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Edit Property Listing (Priority: P1)

As a verified property owner, I want to update the details of my existing listings (price, vacancy status, room features) so that potential tenants always see accurate, real-time information.

**Why this priority**: Correct data is the core value proposition of VacanSee (Principle I). Stale listings lead to user frustration.

**Independent Test**: Can be tested by selecting an existing listing, changing its "Vacancy Status" and "Monthly Price," and verifying the changes reflect immediately on the student search page.

**Acceptance Scenarios**:

1. **Given** an owner is on their dashboard, **When** they click "Edit" on a listing, **Then** a pre-filled form with current listing data is displayed.
2. **Given** the edit form is open, **When** the owner modifies the price and clicks "Save," **Then** the listing is updated and the owner is redirected back to the dashboard with a success notification.

---

### User Story 2 - Delete Property Listing (Priority: P2)

As a verified property owner, I want to remove my listing permanently if the property is no longer for rent or removed from the platform.

**Why this priority**: Removing unavailable properties prevents redundant inquiries and keeps the platform clean.

**Independent Test**: Can be tested by deleting a sample listing and verifying it disappears from both the owner dashboard and the public search results.

**Acceptance Scenarios**:

1. **Given** an owner is on their dashboard, **When** they click "Delete" on a listing, **Then** the system MUST ask for confirmation.
2. **Given** the deletion is confirmed, **When** the process completes, **Then** the listing is removed from the database and UI, and the owner is redirected back to the dashboard with a success notification.

---

### Edge Cases

- **Unauthorized Access**: What happens when a user tries to edit or delete a listing they do not own? (System MUST block this at the repository/RLS level).
- **Network Failure**: How does the system handle a save operation that fails due to connectivity? (System MUST show an error message and retain form data).
- **Incomplete Edits**: What happens if the owner leaves mandatory fields blank during an edit? (System MUST prevent submission and highlight missing fields).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an accessible "Edit" button for every listing in the `OwnerDashboard`.
- **FR-002**: System MUST provide a "Delete" button with a secondary confirmation modal. Successful deletion MUST also purge associated Room records and all uploaded images from Supabase Storage to maintain quota.
- **FR-003**: System MUST validate owner identity (matching `owner_id` with current user UID) before performing any mutation.
- **FR-004**: Edit forms MUST be pre-populated with existing listing data from Supabase.
- **FR-005**: All updates MUST be broadcasted via real-time listeners so students see changes instantly without refresh.
- **FR-006**: System MUST support full management of multi-room listings during the edit flow, including adding new room types, updating existing ones, and removing decommissioned rooms.
- **FR-007**: System MUST allow owners to manage property images granularly during edit, supporting individual deletions of current images and uploads of new ones.
- **FR-008**: If the primary property address is modified during an edit, the system MUST automatically reset the property's verification status to `Pending` and notify the owner.

### Key Entities

- **Property**: The primary listing object containing metadata (name, address, owner_id, status).
- **Room**: Sub-entities belonging to a Property, defining capacity, features, and individual vacancy.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Owners can reach the edit form for any of their listings in under 1 second from the dashboard.
- **SC-002**: Updated listing information is reflected in the student search view in under 2 seconds (Real-time update latency).
- **SC-003**: 100% of deletion operations require a manual confirmation step.
- **SC-004**: System blocks all cross-owner edit/delete attempts (Security/Privacy success).

## Assumptions

- Owners are already authenticated via Supabase Auth and verified by an Admin (per Constitution Principle II).
- The `Property` model already contains an `owner_id` field for ownership verification.
- Relational mapping between Properties and Rooms is already established in the underlying Supabase schema.
- Mobile-first responsiveness is applied to all new management UI components (per Constitution Principle IV).

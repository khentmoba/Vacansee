# Feature Specification: Stealth Admin Access

**Feature Branch**: `008-stealth-admin-access`  
**Created**: 2026-04-17
**Status**: Draft  
**Input**: User description: "i want to add admin access but it be weird and unprofessional if theres a dedicated 'admin' login page right, so how can we access it in admin mode, i need it so we can verify owners and maintain the tenant owners ecosystem"

## Clarifications

### Session 2026-04-17
- Q: Beyond verifying properties, what other ecosystem maintenance actions are required? → A: Property Verification Only.
- Q: How should admins be notified when a new property listing is waiting for verification? → A: Dashboard Badge Only.
- Q: When an admin rejects a property listing, should the owner receive a specific reason? → A: Mandatory Feedback.
- Q: Once a property listing is rejected, what is the expected workflow for the owner? → A: Edit and Re-submit.
- Q: Can an admin reverse or change their decision after verifying or rejecting a property? → A: Full Reversibility.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Stealth Entry to Admin Portal (Priority: P1)

As an administrator, I want to access the admin portal through a discreet interaction rather than a public link, so that the student/owner experience remains professional and uncluttered.

**Why this priority**: Core requirement to avoid "unprofessional" admin links while enabling management.

**Independent Test**: Can be tested by performing the "secret" interaction (e.g., clicking the app logo 5 times in the footer) and verifying that the Admin Portal becomes accessible to authorized users.

**Acceptance Scenarios**:

1. **Given** I am logged in with an `admin` role, **When** I click the footer version number/logo 5 times rapidly, **Then** I am navigated to the Hidden Admin Dashboard.
2. **Given** I am logged in with a `student` or `owner` role, **When** I perform the secret interaction, **Then** I see an "Access Denied" notification or the interaction does nothing.

---

### User Story 2 - Property Verification Workflow (Priority: P2)

As an administrator, I want to see a list of properties pending verification so that I can ensure only legitimate listings are shown to students.

**Why this priority**: Essential for maintaining the "verified listings" value proposition.

**Independent Test**: Can be tested by creating a new property as an owner (defaults to 'pending') and verifying it appears in the Admin Portal's "Pending Verification" list.

**Acceptance Scenarios**:

1. **Given** there are properties with 'pending' status, **When** I view the Admin Dashboard, **Then** I see a list of these properties with their details.
2. **Given** a pending property, **When** I click "Verify", **Then** the property status updates to 'verified' and it becomes visible in the student search.
3. **Given** a pending property, **When** I click "Reject" (or Delete), **Then** the listing is removed or marked as 'deleted'.

---

### User Story 3 - Owner Listing Oversight (Priority: P3)

As an administrator, I want to see a summary of the tenant-owner ecosystem (total listings, total users) to maintain the platform.

**Why this priority**: Helps with overall ecosystem maintenance.

**Independent Test**: Can be tested by viewing the Admin Dashboard summary cards.

**Acceptance Scenarios**:

1. **Given** I am in the Admin Portal, **When** I view the "Stats" tab, **Then** I see counts of active students, owners, and verified properties.

---

### Edge Cases

- **Interaction Miss**: What happens when the user clicks 4 times instead of 5? (Counter resets after short timeout).
- **Session Expiry**: How does the system handle an admin session expiring while in the portal? (Redirects to login, portal becomes inaccessible).
- **Direct URL Access**: If a student guesses the `/admin-secret` URL, they MUST be blocked by RLS/Auth guards.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST implement a "Secret Interaction" (5 rapid clicks on the footer logo/version text) to trigger the Admin Portal entry for authorized admins.
- **FR-002**: System MUST restrict Admin Portal visibility and route access to users with `role = 'admin'`.
- **FR-003**: System MUST provide an Admin Dashboard with a "Property Verification" queue.
- **FR-004**: System MUST allow Admins to change property status between 'pending', 'verified', and 'rejected' at any time.
- **FR-005**: Admins MUST provide a mandatory reason when updating status to 'rejected'.
- **FR-006**: System MUST log admin actions (verification/rejection) for audit purposes.
- **FR-007**: The "Secret Interaction" MUST provide subtle visual feedback only to logged-in admins (e.g., a small loading spinner or transient glow).
- **FR-008**: System MUST display a subtle notification badge/count to admins when properties are in 'pending' status.
- **FR-009**: System MUST allow owners to edit 'rejected' listings; saving changes MUST reset status to 'pending'.

### Key Entities *(include if feature involves data)*

- **AdminPortal**: A protected UI layer for system maintenance.
- **Property**: The primary entity requiring moderation (status field).
- **User**: The role-based entity (specifically the 'admin' variant).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero public-facing links to the Admin Portal are visible to standard users.
- **SC-002**: Admins can verify a pending property listing in under 20 seconds once logged in.
- **SC-003**: 100% of properties created by owners are initially held in 'pending' status until verified.

## Assumptions

- **Existing Role**: The system already distinguishes between `student`, `owner`, and `admin` in the user model.
- **Landing Page**: The secret interaction will be placed on the main landing page or footer which is accessible from everywhere.
- **Simple UI**: The first version of the admin portal will focus exclusively on property verification.
- **Security**: Supabase RLS policies for `admin` role are already configured or will be updated to allow global oversight.


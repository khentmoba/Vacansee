# Feature Specification: Onboarding Role Selection

**Feature Branch**: `009-onboarding-role-selection`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "it directly becomes student when google login is used, i want them to be able to choose between student(tenant) or owner(still needs verification from admin)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - New User Role Selection (Priority: P1)

As a new user logging in for the first time, I want to choose my account type so that I can access the features relevant to my needs (either finding a room or listing one).

**Why this priority**: Correct role assignment is fundamental to the user experience and system security.

**Independent Test**: Can be tested by creating a new account and verifying the role selection screen appearing before the main application features.

**Acceptance Scenarios**:

1. **Given** a new user who has never logged in, **When** they complete the initial authentication, **Then** they are presented with a screen to choose between "Student" and "Owner".
2. **Given** the role selection screen, **When** the user selects "Student", **Then** their profile is updated with the student role and they are redirected to the student explorer interface.

---

### User Story 2 - Owner Verification Onboarding (Priority: P2)

As a new property owner, I want to select the "Owner" role and understand that my account requires verification before I can manage listings.

**Why this priority**: Ensures data quality and trust by preventing unverified owners from posting properties.

**Independent Test**: Can be tested by selecting "Owner" during onboarding and verifying the account enters a "pending" or "unverified" state.

**Acceptance Scenarios**:

1. **Given** the role selection screen, **When** the user selects "Owner", **Then** their profile is updated with the owner role.
2. **Given** a new owner account, **When** they attempt to access property management features, **Then** they see a message indicating their account is awaiting verification.

---

### User Story 3 - Persistence of Role (Priority: P1)

As a returning user, I want to be automatically directed to my dashboard so that I don't have to select my role every time I log in.

**Why this priority**: Essential for a smooth returning user experience.

**Independent Test**: Can be tested by logging out and logging back in with an account that has already selected a role.

**Acceptance Scenarios**:

1. **Given** a user who has already selected a role, **When** they log in, **Then** they are immediately redirected to their respective dashboard (Student or Owner) without seeing the role selection screen.

---

### Edge Cases

- **Session Interruption**: What happens if the user closes the app during the role selection screen? (Default behavior should be to prompt them again upon next login).
- **Role Switching**: Role selection is permanent for the account. Users cannot change their role after the initial selection without administrative assistance.
- **Verification Process**: Owners are verified by an administrator. Until verified, they have read-only access to their dashboard and cannot create or publish new listings.

## Clarifications

### Session 2026-04-17
- Q: Should role selection be strictly mandatory? → A: Mandatory (Access to all app features is strictly blocked until a role is selected).
- Q: Should users provide contact info during onboarding? → A: Basic Profile (Users must confirm display name and provide a mandatory phone number alongside role selection).
- Q: Should admins be notified of new owners? → A: Automated Alert (The system automatically triggers a notification to administrators when a new user selects the "Owner" role).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect if an authenticated user has an unassigned role or missing phone number in their profile.
- **FR-002**: System MUST strictly block access to all application functional interfaces (Dashboard, Explore, Profile) until a role is selected and basic profile data (Name, Phone) is persisted.
- **FR-003**: System MUST provide a UI for role selection + data entry with:
    - Choice between Student and Owner.
    - Editable Display Name field (pre-filled from authenticating provider).
    - Mandatory Phone Number field with format validation.
- **FR-004**: System MUST update the user profile with the selected role and provided contact information.
- **FR-005**: System MUST implement a "Verification Required" state for accounts with the owner role.
- **FR-006**: System MUST restrict owners from creating or publishing items until their account is marked as verified.
- **FR-007**: System MUST automatically notify administrators when a new user registers with the "Owner" role to facilitate timely verification.

### Key Entities *(include if feature involves data)*

- **User**: Represents the authenticated individual. Key attributes: `id`, `identity`, `role`, `verification_status`.
- **Role**: Definition of the user's permissions and available features (Student, Owner, Admin).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of new users are presented with the role selection screen if no role exists on their first login.
- **SC-002**: Users can complete the role selection process in under 15 seconds (median time).
- **SC-003**: 0% of unverified owners are able to bypass the verification gate to manage content.

## Assumptions

- The authentication system provides a unique identifier for each user.
- User Profile storage supports persisting role and verification status.
- Verification will be handled as an asynchronous process by an administrator.
- Once a role is selected, it is intended to be the primary identity for that account.

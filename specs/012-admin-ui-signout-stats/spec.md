# Feature Specification: Admin Signout and Dashboard Polish

**Feature Branch**: `012-admin-ui-signout-stats`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "add a signout as an admin, make the properties owners and ecosystem more white so it can fully be seen, and add the ecosystem statistics"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure Admin Signout (Priority: P1)

As an Admin, I want to be able to sign out of the dashboard so that I can secure my session when I am finished with administrative tasks.

**Why this priority**: Essential for security and session management.

**Independent Test**: Can be tested by clicking the signout button and verifying redirection to the login screen and clearing of session state.

**Acceptance Scenarios**:

1. **Given** the Admin is on any Admin Dashboard screen, **When** they click the "Sign Out" button, **Then** they are redirected to the login screen.
2. **Given** the Admin has signed out, **When** they try to navigate back to the dashboard via URL, **Then** they are blocked and redirected to login.

---

### User Story 2 - High-Visibility Dashboard UI (Priority: P2)

As an Admin, I want the properties, owners, and ecosystem sections to have a high-contrast (whiter) design so that the information is clearly visible and readable.

**Why this priority**: Improves usability and professional aesthetic of the admin interface.

**Independent Test**: Can be visually verified by comparing current UI with the updated high-contrast "white" theme.

**Acceptance Scenarios**:

1. **Given** the Admin views the "Properties" section, **When** the screen loads, **Then** the background and containers use a clean white/high-contrast palette for maximum readability.
2. **Given** the Admin views the "Owners" or "Ecosystem" sections, **When** navigating between them, **Then** the UI remains consistent with the high-visibility theme.

---

### User Story 3 - Ecosystem Statistics Overview (Priority: P2)

As an Admin, I want to see platform-wide statistics (ecosystem stats) on my dashboard so that I can quickly assess the growth and status of VacanSee.

**Why this priority**: Provides critical business intelligence and oversight for the platform.

**Independent Test**: Can be verified by checking the counts displayed against the actual records in the database.

**Acceptance Scenarios**:

1. **Given** the Admin is on the main dashboard/ecosystem view, **When** the page loads, **Then** they see summary cards showing totals for Properties, Owners, and Students.
2. **Given** new records are added to the system, **When** the Admin refreshes the dashboard, **Then** the statistics reflect the updated counts.

---

### Edge Cases

- **Session Expiry**: How does the system handle an admin session expiring while they are viewing stats?
- **Empty State**: What is displayed in the statistics section if there are zero records in the database?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Admin Dashboard MUST include a "Sign Out" action located within a **User Profile Dropdown** in the top-right header.
- **FR-002**: The "Properties" tab UI MUST use **White Card Containers** on a Light Grey background for high contrast.
- **FR-003**: The "Owners" tab UI MUST match the high-contrast white card theme.
- **FR-004**: The "Ecosystem" section MUST match the high-contrast white card theme.
- **FR-005**: System MUST aggregate and display counts as **Simple Number Cards** (refreshed on page load or manual refresh) for:
    - Total Properties (Verified vs. Unverified)
    - Total Property Owners
    - Total Registered Students
- **FR-006**: Statistics MUST be displayed at the **Top of the Dashboard** as summary cards.

## Clarifications

### Session 2026-05-07
- Q: Where should the ecosystem statistics be placed? → A: Top of the Dashboard (as summary cards).
- Q: How should these statistics be visually represented? → A: Simple Number Cards.
- Q: Where should the signout button be located? → A: User Profile Dropdown (Top-right).
- Q: How should the statistics stay updated? → A: Page Load + Manual Refresh.
- Q: What level of UI "whiteness" is required? → A: White Card Containers on Light Grey background.

### Key Entities *(include if feature involves data)*

- **Ecosystem Stats**: A data object containing counts for properties, owners, and students.
- **Admin User**: The user role with permissions to view these stats and perform signout.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Admin can complete the signout process in under 2 seconds.
- **SC-002**: All text in the "Properties", "Owners", and "Ecosystem" sections meets AA contrast ratio standards (4.5:1).
- **SC-003**: Statistics accurately reflect 100% of the data in the Supabase backend.
- **SC-004**: Dashboard load time (including stats fetching) remains under 1.5 seconds.

## Assumptions

- "Ecosystem statistics" includes counts of the three main entities: Properties, Owners, and Students/Users.
- "More white" refers to moving away from dark/grey backgrounds in favor of a clean, premium white interface for data containers.
- Statistics can be fetched using simple count queries from Supabase.

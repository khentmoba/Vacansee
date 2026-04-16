**Input**: User description: "the delete function on the owner is not working so fix it, also the domain of the deploy is not the usual domain which is 'https://vacansee-six.vercel.app', fix it aswell, and add a feature in google authenthication where the email used in register and thhe email in the google account is the same, then its gonna be one account and either of them can log in using that"

## Clarifications

### Session 2026-04-17
- **Q**: What is the official deployment domain? → **A**: `vacansee-xi.vercel.app` (Recommended for consistency with existing code).
- **Q**: How should the delete function be fixed? → **A**: Harden image path extraction and ensure DB deletion is atomic regardless of storage cleanup result.
- **Q**: How should Google Auth linking be handled? → **A**: Automatic merging of accounts sharing the same email is preferred (Dashboard setting + code handling).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure Property Deletion (Priority: P1)

As a property owner, I want to be able to permanently delete my property listings and all associated rooms and images, so that I can remove outdated or incorrect information from the platform.

**Why this priority**: Core functionality for property management. Currently broken.

**Independent Test**: Delete a listing with multiple rooms and images. Verify it disappears from the dashboard and the images are removed from storage.

**Acceptance Scenarios**:

1. **Given** an owner with a listing, **When** they click Delete and confirm, **Then** the listing and all its rooms are removed from the database.
2. **Given** a listing with images in Supabase storage, **When** the listing is deleted, **Then** the associated storage objects are also removed.

---

### User Story 2 - Consistent Branding & Redirects (Priority: P2)

As a user, I want all links (including password resets) and metadata to point to the correct official domain, so that the experience is consistent and trust is maintained.

**Why this priority**: Avoids phishing warnings and inconsistent UX.

**Independent Test**: Send a password reset email and verify the link points to the "usual" domain. Inspect page metadata (OG tags).

**Acceptance Scenarios**:

1. **Given** a password reset request, **When** an email is sent, **Then** the redirect link matches the standardized domain.
2. **Given** the app's landing page, **When** viewed on social media, **Then** the preview link matches the standardized domain.

---

### User Story 3 - Unified Identity (Priority: P1)

As a user who registered with an email and password, I want to be able to sign in with Google using the same email and access the same account, so that I don't create duplicate accounts.

**Why this priority**: Essential for UX and data integrity. Prevents fragmented user profiles.

**Independent Test**: Register `user@example.com` with password. Then Sign in with Google using `user@example.com`. Verify both logins lead to the same user ID.

**Acceptance Scenarios**:

1. **Given** an existing email/password account, **When** signing in with Google using the same email, **Then** the user is logged into the existing account.

---

### Edge Cases

- **Partial Delete**: What happens if the DB delete succeeds but storage cleanup fails? (System should log error but complete the primary task).
- **Email Mismatch**: If a Google account has a different email than the one intended for linking. (Should create a new account or require manual link).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a robust `deletePropertyListing` method that cleans up DB and Storage assets.
- **FR-002**: System MUST standardize all occurrences of `vacansee-*.vercel.app` to the confirmed official domain.
- **FR-003**: System MUST identify existing accounts during Google Sign-in based on email.
- **FR-004**: System MUST ensure that account linking results in a single, unified `UserModel` record.

### Key Entities

- **Property**: The listing being deleted (includes images list).
- **User**: The identity being linked (indexed by email).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of property deletions successfully remove all DB entries and at least 95% of storage assets (due to potential storage orphans).
- **SC-002**: All hardcoded domain references in the frontend and auth service are unified.
- **SC-003**: Users with existing email/password accounts can successfully log in via Google without data loss or profile duplication.

## Assumptions

- The "Link accounts with same email" setting in Supabase is the preferred method for auth merging.
- The official standardized domain is `vacansee-xi.vercel.app`.
- Listing images are stored in the `property_images` bucket with a structure that follows the Supabase public object URL pattern.

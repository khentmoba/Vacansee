# Research: Stealth Admin Access

This research resolves unknowns regarding implementation of the hidden admin portal and secret interaction.

## Findings

### Admin Role Implementation
- **Decision**: Use the existing `UserRole.admin` in `UserModel`.
- **Rationale**: The enum and database type already support it. `AuthProvider` just needs a helper getter `isAdmin`.
- **First Admin**: Must be manually promoted via Supabase SQL Editor for security.

### Secret Interaction (5-Click Sequence)
- **Decision**: Implement a `SecretInteractionWrapper` widget.
- **Rationale**: Keeps the logic encapsulated and reusable. It will track clicks and reset the counter after 500ms of inactivity.
- **Target**: The app title or logo in `AppBar`.

### Property Moderation Logic
- **Decision**: Add `rejected` to `PropertyStatus` enum and `rejection_reason` (String?) to `PropertyModel`.
- **Database**: Add `rejected` to `property_status` enum and `rejection_reason TEXT` to `properties` table.
- **Service**: Add `moderateProperty(String id, PropertyStatus status, {String? reason})` to `PropertyService`.

### Admin Dashboard UI
- **Decision**: Use a simple `TabView` or `ListView` showing 'Pending' properties.
- **Rationale**: Aligns with the "Performant Simplicity" principle. No heavy dashboard libraries.

## Alternatives Considered
- **Dedicated Admin Login**: Rejected by user ("unprofessional").
- **Keyboard Shortcut**: Rejected (Not mobile-friendly).
- **Hidden Route only**: Rejected (Too easy to guess; needs interaction guard).

## Research Resolved

- [x] How is role handled? (In `UserModel` and `AuthProvider`).
- [x] How to implement 5 clicks? (Custom counter widget).
- [x] Where to place the secret knock? (Home AppBar).
- [x] How to handle rejection feedback? (New DB column and Model field).

# Research: Admin Dashboard Polish

## Decision: Implementation of User Profile Dropdown
- **Decision**: Use a `PopupMenuButton` in the `AppBar` actions.
- **Rationale**: standard Flutter pattern for profile menus. It provides a clean way to hide the signout action while remaining accessible.
- **Alternatives**: A separate sidebar button (rejected for UI clutter) or a dedicated logout icon (rejected in favor of the requested "User Profile Dropdown" pattern).

## Decision: Ecosystem Statistics Aggregation
- **Decision**: Implement a `getEcosystemStats` method in a new `AdminService` that performs three `count()` queries in parallel.
- **Rationale**: Efficient and utilizes Supabase's built-in count functionality. 
- **Alternatives**: Real-time subscriptions (rejected for performance/cost overhead on stats) or Edge Functions (rejected to keep logic simple within the Flutter app).

## Decision: UI Theme Refactor ("More White")
- **Decision**: Update `AdminDashboard` to use a white `AppBar` with dark text and wrap tab content in `Card` widgets with elevation 0 and subtle borders.
- **Rationale**: Meets the "more white" and "fully be seen" requirements by providing a clean, high-contrast dashboard layout.
- **Alternatives**: Global Light/Dark mode (rejected as it exceeds current scope).

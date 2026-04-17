# Research: Real-time Publishing and Role Selection

## Decision: Supabase Auth Metadata for initial role detection
- **Rationale**: When using Google OAuth, the user is created in Supabase Auth before our triggers run. We can check for a missing `role` in the `users` table to trigger the `RoleSelectionScreen`.
- **Alternatives considered**: Storing role strictly in `auth.users.raw_user_meta_data`. Rejected because our RLS and queries depend on the `public.users` table.

## Decision: Explicit Stream management in Providers
- **Rationale**: To achieve real-time publishing and booking count updates, we must use `.stream()` from `supabase_flutter`.
- **Alternatives considered**: Polling. Rejected due to performance and user experience requirements.

## Decision: Mandatory Role Guard in AuthWrapper
- **Rationale**: Implementing a clean redirect in the `AuthWrapper` (L87 in main.dart) ensures no "role-less" user can ever reach the dashboards.
- **Decision**: Add `AuthStatus.needsRole` and check for `user.role == null`.

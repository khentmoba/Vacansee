# Quickstart: Onboarding Role Selection

## Developer Setup
1. **Database Update**: Apply the schema changes from `data-model.md` in the Supabase SQL editor. This adds the `is_verified` column and the admin notification trigger.
2. **Environment**: Ensure `.env` is loaded (already handled in `main.dart`).

## Verification Steps

### 1. New User Flow (Google Login)
- Log in with a new Google Account.
- **Expected**: App redirects to `RoleSelectionScreen`.
- **Action**: Select a role, edit name, and enter a phone number. Click "Get Started".
- **Expected**: 
    - Profile updated in `public.users` with role, name, and phone.
    - If "Owner" selected, `is_verified` is `false`.
    - If "Owner" selected, a notification appears in `public.admin_notifications`.
    - User is taken to their respective dashboard (`HomeScreen`).

### 2. Mandatory Enforcement
- Try to navigate to `/home` or `/profile` manually (if web URL supports it) before selecting a role.
- **Expected**: `AuthWrapper` should automatically bounce the user back to `/onboarding` (RoleSelectionScreen) if `role` is null.

### 3. Returning User flow
- Log out and log back in with the same account.
- **Expected**: User skip the onboarding screen and lands directly on their dashboard.

## Common Issues
- **Notification not firing**: Check if the Supabase trigger `on_owner_registration` is enabled on the `public.users` table.
- **Role not saved**: Ensure the `AuthService.updateProfile` call is correctly passing the `role` enum name.

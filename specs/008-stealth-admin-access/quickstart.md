# Quickstart: Stealth Admin Access

This guide explains how to access and test the hidden admin portal.

## 1. Promoting an Administrator
Access to the portal is restricted to users with the `admin` role. Since there is no UI for promoting users, this must be done via the Supabase SQL Editor:

```sql
UPDATE public.users 
SET role = 'admin' 
WHERE email = 'your-email@example.com';
```

## 2. Entering Admin Mode (The "Secret Knock")
1. Log in with your admin account.
2. Go to the Home Screen (Student or Owner dashboard).
3. **Action**: Click/Tap the "VacanSee" logo in the top AppBar **5 times rapidly** (within 2 seconds).
4. **Feedback**: A subtle glow or loading indicator will appear briefly.
5. **Result**: You will be navigated to the Hidden Admin Dashboard.

## 3. Moderation Workflow
- **Pending List**: Shows all listings with `status = 'pending'`.
- **Verify**: One-tap verification. Listing becomes public immediately.
- **Reject**: Opens a dialog to provide a reason. listing is hidden from search.
- **Undo**: Go to the "Verified" or "Rejected" tabs to move a listing back to another state if a mistake was made.

## 4. Verification Check
- As an **Owner**: Create a listing. It should appear in the Admin's "Pending" list.
- As an **Admin**: Verify the listing.
- As a **Student**: The listing should now appear in the search results.

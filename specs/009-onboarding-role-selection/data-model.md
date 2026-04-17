# Data Model: Onboarding Role Selection

## Entities

### User (public.users)
Represents the core user profile.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Primary key (FK to auth.users). |
| `email` | TEXT | User's email address. |
| `display_name` | TEXT | User's chosen display name. |
| `role` | user_role | Enum: 'student', 'owner', 'admin'. |
| `phone_number` | TEXT | Mandatory contact number (verified or captured during onboarding). |
| `is_verified` | BOOLEAN | **[NEW]** Indicates if the user account is verified (default: false for owners). |
| `created_at` | TIMESTAMPTZ | Timestamp of profile creation. |

### Admin Notification (public.admin_notifications)
Logs events requiring administrative action.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Primary key. |
| `user_id` | UUID | User associated with the notification (FK to users.id). |
| `type` | TEXT | Type of notification (e.g., 'new_owner_registration'). |
| `content` | TEXT | Description of the event. |
| `is_read` | BOOLEAN | Tracking status for admins. |
| `created_at` | TIMESTAMPTZ | Timestamp of event. |

## Relationships
- `User` 1:N `Admin Notification` (Admin notification traces back to a specific user).

## Schema Changes (SQL)

```sql
-- Add is_verified safely
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- Create admin_notifications table
CREATE TABLE IF NOT EXISTS public.admin_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for admin_notifications
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all notifications" 
ON public.admin_notifications FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

-- Trigger for new owner notification
CREATE OR REPLACE FUNCTION public.notify_admin_on_owner_registration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'owner' AND (OLD.role IS NULL OR OLD.role != 'owner') THEN
    INSERT INTO public.admin_notifications (user_id, type, content)
    VALUES (NEW.id, 'new_owner_registration', 'A new user has registered as an owner and requires verification: ' || NEW.display_name);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_owner_registration
  AFTER UPDATE OF role ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_admin_on_owner_registration();
```

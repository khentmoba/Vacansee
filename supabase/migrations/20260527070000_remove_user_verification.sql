-- Migration: Remove user verification column and related triggers
-- Owner/tenant verification is no longer used; only property listing approval remains

-- 1. Drop owner registration notification trigger
DROP TRIGGER IF EXISTS on_owner_registration ON public.users;
DROP FUNCTION IF EXISTS public.notify_admin_on_owner_registration;

-- 2. Drop admin_notifications table (was only for owner verification alerts)
DROP TABLE IF EXISTS public.admin_notifications;

-- 3. Drop is_verified column from users table
ALTER TABLE public.users DROP COLUMN IF EXISTS is_verified;

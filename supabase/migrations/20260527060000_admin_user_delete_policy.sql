-- Migration: Add DELETE policy for admin on users table
-- Admin users can delete any user profile from the admin panel

DROP POLICY IF EXISTS "Admins can delete users" ON public.users;
CREATE POLICY "Admins can delete users"
ON public.users FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

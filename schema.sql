-- VacanSee Supabase Schema Definition
-- Run this in the Supabase SQL Editor

-- 1. Create Custom Types (Enums)
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('student', 'owner', 'admin');
EXCEPTION WHEN duplicate_object THEN 
    -- If it exists, ensure newest values are added
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
END $$;

DO $$ BEGIN
    CREATE TYPE gender_orientation AS ENUM ('male', 'female', 'mixed');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE room_status AS ENUM ('vacant', 'occupied', 'maintenance');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE booking_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled', 'completed');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE property_status AS ENUM ('pending', 'verified', 'rejected', 'deleted');
EXCEPTION WHEN duplicate_object THEN 
    -- If it exists, ensure newest values are added
    ALTER TYPE property_status ADD VALUE IF NOT EXISTS 'rejected';
END $$;

-- 2. Create Tables

-- Users Table (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role user_role, -- Nullable initially for role selection flow
  phone_number TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false, -- true for verified owners; always true for students/admin
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- Ensure is_verified column exists on existing tables
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT false;

-- Admin Notifications Table (for owner verification alerts)
CREATE TABLE IF NOT EXISTS public.admin_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Properties Table
CREATE TABLE IF NOT EXISTS public.properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  gender_orientation gender_orientation NOT NULL DEFAULT 'mixed',
  amenities TEXT[] DEFAULT '{}',
  price_range JSONB NOT NULL,
  status property_status NOT NULL DEFAULT 'pending',
  images TEXT[] DEFAULT '{}',
  description TEXT,
  rejection_reason TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rooms Table
CREATE TABLE IF NOT EXISTS public.rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
  status room_status NOT NULL DEFAULT 'vacant',
  images TEXT[] DEFAULT '{}',
  capacity INTEGER NOT NULL,
  current_occupants INTEGER NOT NULL DEFAULT 0,
  monthly_rate INTEGER NOT NULL,
  description TEXT,
  last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
  room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
  property_name TEXT NOT NULL,
  room_description TEXT NOT NULL,
  student_name TEXT NOT NULL,
  student_email TEXT NOT NULL,
  student_phone TEXT,
  status booking_status NOT NULL DEFAULT 'pending',
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMPTZ,
  student_notes TEXT,
  owner_notes TEXT,
  move_in_date TIMESTAMPTZ,
  duration_months INTEGER NOT NULL DEFAULT 1
);

-- Ensure new columns exist for existing tables
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS property_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS room_description TEXT;
-- Ensure property_name and room_description are NOT NULL if table existed
ALTER TABLE public.bookings ALTER COLUMN property_name SET NOT NULL;
ALTER TABLE public.bookings ALTER COLUMN room_description SET NOT NULL;

-- 3. Enable extensions required
-- (None specific for now, pgcrypto is usually enabled by default for uuid)

-- 4. Set up Row Level Security (RLS) policies

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;

-- Admin Notifications RLS
DROP POLICY IF EXISTS "Admins can view all notifications" ON public.admin_notifications;
CREATE POLICY "Admins can view all notifications"
ON public.admin_notifications FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

DROP POLICY IF EXISTS "Admins can update notifications" ON public.admin_notifications;
CREATE POLICY "Admins can update notifications"
ON public.admin_notifications FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

DROP POLICY IF EXISTS "Service role can insert notifications" ON public.admin_notifications;
CREATE POLICY "Service role can insert notifications"
ON public.admin_notifications FOR INSERT WITH CHECK (true); -- Triggered by server-side function


-- Users RLS
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view their own profile" 
ON public.users FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Public profiles are viewable by anyone" ON public.users;
CREATE POLICY "Public profiles are viewable by anyone" 
ON public.users FOR SELECT USING (true); -- needed for owner details, etc.

DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile" 
ON public.users FOR UPDATE USING (auth.uid() = id);


DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
CREATE POLICY "Enable insert for authenticated users only"
ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Properties RLS
DROP POLICY IF EXISTS "Public can view verified properties" ON public.properties;
CREATE POLICY "Public can view verified properties" 
ON public.properties FOR SELECT USING (status = 'verified');

DROP POLICY IF EXISTS "Owners can view their own properties" ON public.properties;
CREATE POLICY "Owners can view their own properties" 
ON public.properties FOR SELECT USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can insert their own properties" ON public.properties;
CREATE POLICY "Owners can insert their own properties" 
ON public.properties FOR INSERT WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can update their own properties" ON public.properties;
CREATE POLICY "Owners can update their own properties" 
ON public.properties FOR UPDATE USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete their own properties" ON public.properties;
CREATE POLICY "Owners can delete their own properties" 
ON public.properties FOR DELETE USING (auth.uid() = owner_id);

-- Admin Global Access
DROP POLICY IF EXISTS "Admins have full access to all properties" ON public.properties;
CREATE POLICY "Admins have full access to all properties" 
ON public.properties FOR ALL USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

-- Rooms RLS
DROP POLICY IF EXISTS "Public can view rooms of verified properties" ON public.rooms;
CREATE POLICY "Public can view rooms of verified properties" 
ON public.rooms FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.status = 'verified'
  )
);

DROP POLICY IF EXISTS "Owners can view all their rooms" ON public.rooms;
CREATE POLICY "Owners can view all their rooms" 
ON public.rooms FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owners can insert rooms for their properties" ON public.rooms;
CREATE POLICY "Owners can insert rooms for their properties" 
ON public.rooms FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = property_id AND p.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owners can update rooms for their properties" ON public.rooms;
CREATE POLICY "Owners can update rooms for their properties" 
ON public.rooms FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owners can delete rooms for their properties" ON public.rooms;
CREATE POLICY "Owners can delete rooms for their properties" 
ON public.rooms FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

-- Bookings RLS
DROP POLICY IF EXISTS "Students can view their own bookings" ON public.bookings;
CREATE POLICY "Students can view their own bookings" 
ON public.bookings FOR SELECT USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Owners can view bookings for their properties" ON public.bookings;
CREATE POLICY "Owners can view bookings for their properties" 
ON public.bookings FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = bookings.property_id AND p.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Students can insert their own bookings" ON public.bookings;
CREATE POLICY "Students can insert their own bookings" 
ON public.bookings FOR INSERT WITH CHECK (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can update their own bookings to cancel" ON public.bookings;
CREATE POLICY "Students can update their own bookings to cancel" 
ON public.bookings FOR UPDATE USING (auth.uid() = student_id)
WITH CHECK (status = 'cancelled');

DROP POLICY IF EXISTS "Owners can update bookings for their properties" ON public.bookings;
CREATE POLICY "Owners can update bookings for their properties" 
ON public.bookings FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = bookings.property_id AND p.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Students can delete their own bookings if pending" ON public.bookings;
CREATE POLICY "Students can delete their own bookings if pending"
ON public.bookings FOR DELETE USING (auth.uid() = student_id AND status = 'pending');

-- 5. Storage Buckets (Optional, configure separately in dash but here is standard)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('property_images', 'property_images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
USING ( bucket_id = 'property_images' );

DROP POLICY IF EXISTS "Owners can upload images" ON storage.objects;
CREATE POLICY "Owners can upload images" 
ON storage.objects FOR INSERT 
WITH CHECK ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

DROP POLICY IF EXISTS "Owners can update their images" ON storage.objects;
CREATE POLICY "Owners can update their images"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

DROP POLICY IF EXISTS "Owners can delete their images" ON storage.objects;
CREATE POLICY "Owners can delete their images"
ON storage.objects FOR DELETE
USING ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

-- 6. Views
-- Real-time vacancy view with property join
-- 7. Triggers for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  default_role public.user_role;
BEGIN
  -- Safe role extraction
  BEGIN
    default_role := (NEW.raw_user_meta_data->>'role')::public.user_role;
  EXCEPTION WHEN OTHERS THEN
    default_role := NULL;
  END;

  INSERT INTO public.users (id, email, display_name, role, phone_number)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
    default_role,
    NEW.raw_user_meta_data->>'phone_number'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    display_name = EXCLUDED.display_name,
    role = COALESCE(EXCLUDED.role, public.users.role), -- Preserve existing role if metadata is empty
    phone_number = COALESCE(EXCLUDED.phone_number, public.users.phone_number),
    last_login_at = NOW();
    
  RETURN NEW;
END;
$$;

-- 8. Owner Registration Notification Trigger
-- Fires when a user's role is set to 'owner', creating a notification for admins.
CREATE OR REPLACE FUNCTION public.notify_admin_on_owner_registration()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only fire when a role is being set to 'owner' for the first time
  IF NEW.role = 'owner' AND (OLD.role IS NULL OR OLD.role != 'owner') THEN
    INSERT INTO public.admin_notifications (user_id, type, content)
    VALUES (
      NEW.id,
      'new_owner_registration',
      'New owner registered and requires verification: ' || NEW.display_name || ' (' || NEW.email || ')'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_owner_registration ON public.users;
CREATE TRIGGER on_owner_registration
  AFTER UPDATE OF role ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_admin_on_owner_registration();

-- 9. Enable Realtime Publications

-- Using DO block to safely add tables to publication if they aren't already there
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'properties') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.properties;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'bookings') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'rooms') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
  END IF;
END $$;

-- Trigger to call the function on every user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Real-time vacancy view with property join (Update to ensure view exists after trigger)
CREATE OR REPLACE VIEW public.room_vacancies AS
SELECT 
  r.id,
  r.property_id,
  r.status,
  (r.status = 'vacant') as is_available,
  r.images,
  r.capacity,
  r.current_occupants,
  r.monthly_rate,
  r.description,
  r.last_updated,
  p.name as property_name,
  p.address as property_address,
  (p.status = 'verified') as property_is_verified
FROM public.rooms r
JOIN public.properties p ON r.property_id = p.id;

-- Grant permissions on the view
GRANT SELECT ON TABLE public.room_vacancies TO anon;
GRANT SELECT ON TABLE public.room_vacancies TO authenticated;
GRANT SELECT ON TABLE public.room_vacancies TO service_role;

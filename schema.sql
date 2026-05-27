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
  gender TEXT,
  first_name TEXT,
  last_name TEXT,
  address TEXT,
  business_name TEXT,
  business_permit_no TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
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
  total_rooms INTEGER NOT NULL DEFAULT 0,
  available_rooms INTEGER NOT NULL DEFAULT 0,
  monthly_price INTEGER NOT NULL DEFAULT 0,
  has_vacancy BOOLEAN NOT NULL DEFAULT true,
  average_rating DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  reviews_count INTEGER NOT NULL DEFAULT 0,
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

DROP POLICY IF EXISTS "Admins can update all profiles" ON public.users;
CREATE POLICY "Admins can update all profiles"
ON public.users FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);


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
  extracted_role public.user_role;
BEGIN
  -- 1. Extract role with extreme safety
  BEGIN
    extracted_role := (NEW.raw_user_meta_data->>'role')::public.user_role;
  EXCEPTION WHEN OTHERS THEN
    extracted_role := NULL; -- Ensure we don't crash on invalid enum values
  END;

  -- 2. Perform Upsert with safe defaults
  -- We use COALESCE and NULLIF to ensure required columns like display_name are NEVER null.
  INSERT INTO public.users (
    id, 
    email, 
    display_name, 
    role, 
    phone_number,
    is_verified
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NULLIF(NEW.raw_user_meta_data->>'display_name', ''), 
      NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
      SPLIT_PART(NEW.email, '@', 1) -- Extreme fallback: use email prefix
    ),
    extracted_role,
    NEW.raw_user_meta_data->>'phone_number',
    CASE 
      WHEN extracted_role = 'admin' THEN true 
      WHEN extracted_role = 'student' THEN true
      ELSE false -- Owners default to unverified
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    email         = EXCLUDED.email,
    display_name  = COALESCE(NULLIF(EXCLUDED.display_name, ''), public.users.display_name),
    role          = COALESCE(public.users.role, EXCLUDED.role), -- Don't overwrite existing role with NULL
    phone_number  = COALESCE(EXCLUDED.phone_number, public.users.phone_number),
    last_login_at = NOW();

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Last ditch effort: Log warning but MUST return NEW to let the user login
  RAISE WARNING 'handle_new_user critical failure for %: %', NEW.email, SQLERRM;
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

-- 10. Notifications and Webhooks Setup (consolidated from migrations)

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- booking_request, booking_accepted, booking_declined, booking_expired, system
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Enable RLS for notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;
CREATE POLICY "System can insert notifications"
ON public.notifications FOR INSERT
WITH CHECK (true);

-- Real-time publication for notifications table
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  END IF;
END $$;

-- Triggers and Functions for Bookings

-- Booking status sync trigger (handle_booking_acceptance)
CREATE OR REPLACE FUNCTION public.handle_booking_acceptance()
RETURNS TRIGGER AS $$
BEGIN
    -- If booking is approved
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        -- Mark room as occupied
        UPDATE public.rooms 
        SET status = 'occupied', last_updated = NOW()
        WHERE id = NEW.room_id;

        -- Decline all other pending requests for the same room
        UPDATE public.bookings
        SET status = 'rejected', owner_notes = 'Room already taken', responded_at = NOW()
        WHERE room_id = NEW.room_id AND id <> NEW.id AND status = 'pending';

        -- Notify student with metadata
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
          NEW.student_id, 
          'Booking Approved!', 
          'Your booking for ' || NEW.property_name || ' has been approved.', 
          'booking_accepted',
          jsonb_build_object(
            'booking_id', NEW.id,
            'property_name', NEW.property_name,
            'room_description', NEW.room_description,
            'owner_notes', NEW.owner_notes,
            'status', NEW.status
          )
        );
    
    ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
        -- Notify student of rejection with metadata
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
          NEW.student_id, 
          'Booking Declined', 
          'Your booking request for ' || NEW.property_name || ' was declined.', 
          'booking_declined',
          jsonb_build_object(
            'booking_id', NEW.id,
            'property_name', NEW.property_name,
            'room_description', NEW.room_description,
            'owner_notes', NEW.owner_notes,
            'status', NEW.status
          )
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_booking_status_change ON public.bookings;
CREATE TRIGGER on_booking_status_change
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_booking_acceptance();


-- Booking Request Notification Trigger
CREATE OR REPLACE FUNCTION public.notify_owner_on_booking()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
    room_rate INTEGER;
BEGIN
    -- Get owner_id from property
    SELECT p.owner_id INTO owner_id FROM public.properties p WHERE p.id = NEW.property_id;
    
    -- Get monthly rate from room
    SELECT r.monthly_rate INTO room_rate FROM public.rooms r WHERE r.id = NEW.room_id;

    -- Notify owner with detailed metadata
    INSERT INTO public.notifications (user_id, title, message, type, metadata)
    VALUES (
      owner_id, 
      'New Booking Request', 
      'You have a new booking request for ' || NEW.property_name || ' from ' || NEW.student_name || '.', 
      'booking_request',
      jsonb_build_object(
        'booking_id', NEW.id,
        'property_id', NEW.property_id,
        'room_id', NEW.room_id,
        'property_name', NEW.property_name,
        'room_description', NEW.room_description,
        'monthly_rate', COALESCE(room_rate, 0),
        'student_name', NEW.student_name,
        'student_email', NEW.student_email,
        'student_phone', NEW.student_phone,
        'student_notes', NEW.student_notes,
        'move_in_date', NEW.move_in_date,
        'duration_months', NEW.duration_months
      )
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_booking_created ON public.bookings;
CREATE TRIGGER on_booking_created
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_owner_on_booking();


-- Webhook trigger to send emails via pg_net calling Edge Function
CREATE OR REPLACE FUNCTION public.trigger_notification_email()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  service_role_key TEXT;
BEGIN
  -- Try to retrieve the service role key from the Supabase Vault securely
  BEGIN
    SELECT decrypted_secret INTO service_role_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'service_role_key' 
    LIMIT 1;
  EXCEPTION WHEN OTHERS THEN
    service_role_key := NULL;
  END;

  -- Fallback to current_setting or default anon key if vault query fails/is empty
  IF service_role_key IS NULL THEN
    service_role_key := COALESCE(
      current_setting('vault.service_role_key', true), 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6ZWx5eHZlY2dnd29ybXNvZXNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMTk0NzIsImV4cCI6MjA5MTg5NTQ3Mn0.GInyDYoBe3Tu8aJQ0nOmEVS1mmRNIAYSGW_VmClc2o0'
    );
  END IF;

  PERFORM
    net.http_post(
      url := 'https://hzelyxvecggwormsoesa.supabase.co/functions/v1/send-notification-email',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_role_key
      ),
      body := jsonb_build_object('record', row_to_json(NEW))
    );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_notification_inserted ON public.notifications;
CREATE TRIGGER on_notification_inserted
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_notification_email();


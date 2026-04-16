-- VacanSee Supabase Schema Definition
-- Run this in the Supabase SQL Editor

-- 1. Create Custom Types (Enums)
CREATE TYPE user_role AS ENUM ('student', 'owner', 'admin');
CREATE TYPE gender_orientation AS ENUM ('male', 'female', 'mixed');
CREATE TYPE room_status AS ENUM ('vacant', 'occupied', 'maintenance');
CREATE TYPE booking_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled', 'completed');
CREATE TYPE property_status AS ENUM ('pending', 'verified', 'deleted');

-- 2. Create Tables

-- Users Table (Extends auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'student',
  phone_number TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- Properties Table
CREATE TABLE public.properties (
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
  last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rooms Table
CREATE TABLE public.rooms (
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
CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
  room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
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

-- 3. Enable extensions required
-- (None specific for now, pgcrypto is usually enabled by default for uuid)

-- 4. Set up Row Level Security (RLS) policies

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Users RLS
CREATE POLICY "Users can view their own profile" 
ON public.users FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Public profiles are viewable by anyone" 
ON public.users FOR SELECT USING (true); -- needed for owner details, etc.

CREATE POLICY "Users can update their own profile" 
ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only"
ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Properties RLS
CREATE POLICY "Public can view verified properties" 
ON public.properties FOR SELECT USING (status = 'verified');

CREATE POLICY "Owners can view their own properties" 
ON public.properties FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Owners can insert their own properties" 
ON public.properties FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their own properties" 
ON public.properties FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their own properties" 
ON public.properties FOR DELETE USING (auth.uid() = owner_id);

-- Rooms RLS
CREATE POLICY "Public can view rooms of verified properties" 
ON public.rooms FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.is_verified = true
  )
);

CREATE POLICY "Owners can view all their rooms" 
ON public.rooms FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can insert rooms for their properties" 
ON public.rooms FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = property_id AND p.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can update rooms for their properties" 
ON public.rooms FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can delete rooms for their properties" 
ON public.rooms FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.owner_id = auth.uid()
  )
);

-- Bookings RLS
CREATE POLICY "Students can view their own bookings" 
ON public.bookings FOR SELECT USING (auth.uid() = student_id);

CREATE POLICY "Owners can view bookings for their properties" 
ON public.bookings FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = bookings.property_id AND p.owner_id = auth.uid()
  )
);

CREATE POLICY "Students can insert their own bookings" 
ON public.bookings FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can update their own bookings to cancel" 
ON public.bookings FOR UPDATE USING (auth.uid() = student_id)
WITH CHECK (status = 'cancelled');

CREATE POLICY "Owners can update bookings for their properties" 
ON public.bookings FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = bookings.property_id AND p.owner_id = auth.uid()
  )
);

CREATE POLICY "Students can delete their own bookings if pending"
ON public.bookings FOR DELETE USING (auth.uid() = student_id AND status = 'pending');

-- 5. Storage Buckets (Optional, configure separately in dash but here is standard)
INSERT INTO storage.buckets (id, name, public) VALUES ('property_images', 'property_images', true);

CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
USING ( bucket_id = 'property_images' );

CREATE POLICY "Owners can upload images" 
ON storage.objects FOR INSERT 
WITH CHECK ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

CREATE POLICY "Owners can update their images"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

CREATE POLICY "Owners can delete their images"
ON storage.objects FOR DELETE
USING ( bucket_id = 'property_images' AND auth.role() = 'authenticated' );

-- 6. Views
-- Real-time vacancy view with property join
-- 7. Triggers for automatic profile creation
-- This handles the creation of a 'public.users' row whenever a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, role, phone_number)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'owner' THEN 'owner'::user_role
      WHEN NEW.raw_user_meta_data->>'role' = 'admin' THEN 'admin'::user_role
      ELSE 'student'::user_role
    END,
    NEW.raw_user_meta_data->>'phone_number'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    display_name = EXCLUDED.display_name,
    role = EXCLUDED.role,
    phone_number = EXCLUDED.phone_number;
  RETURN NEW;
END;
$$;

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
  p.is_verified as property_is_verified
FROM public.rooms r
JOIN public.properties p ON r.property_id = p.id;

-- Grant permissions on the view
GRANT SELECT ON TABLE public.room_vacancies TO anon;
GRANT SELECT ON TABLE public.room_vacancies TO authenticated;
GRANT SELECT ON TABLE public.room_vacancies TO service_role;

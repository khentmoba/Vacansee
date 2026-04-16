-- Seed data for testing VacanSee UI
-- IMPORTANT: Use this only in local/test environments!

-- 1. Create a dummy Auth User
-- Warning: The encrypted password here is just a dummy. Use the UI to actually login, or generate your own user via signup.
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_metadata,
  raw_user_metadata,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'owner@vacansee.app',
  '$2a$10$0', -- dummy password hash
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- 2. Insert into public.users
INSERT INTO public.users (
  id,
  email,
  display_name,
  role,
  phone_number
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'owner@vacansee.app',
  'Test Owner',
  'owner',
  '+639123456789'
) ON CONFLICT (id) DO NOTHING;

-- 3. Insert Dummy Properties
INSERT INTO public.properties (
  id,
  owner_id,
  name,
  address,
  lat,
  lng,
  gender_orientation,
  amenities,
  price_range,
  is_verified,
  description,
  cover_image_url
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  '00000000-0000-0000-0000-000000000001',
  'Sunshine Boarding House',
  '123 University Ave, CDO',
  8.48222,
  124.64722,
  'mixed',
  ARRAY['WiFi', 'Air Conditioning', 'Study Area'],
  '{"min": 3500, "max": 5500}',
  true,
  'A peaceful boarding house close to the university with all basic amenities.',
  'https://images.unsplash.com/photo-1555854877-bab0e564b8d5'
),
(
  '22222222-2222-2222-2222-222222222222',
  '00000000-0000-0000-0000-000000000001',
  'Acacia Ladies Dorm',
  '456 Acacia St, CDO',
  8.48511,
  124.64611,
  'female',
  ARRAY['WiFi', 'Security', 'Laundry'],
  '{"min": 4000, "max": 6000}',
  true,
  'Exclusive dormitory for female students with 24/7 security.',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'
) ON CONFLICT (id) DO NOTHING;

-- 4. Insert Dummy Rooms
INSERT INTO public.rooms (
  id,
  property_id,
  status,
  images,
  capacity,
  current_occupants,
  monthly_rate,
  description
) VALUES (
  '33333333-3333-3333-3333-333333333331',
  '11111111-1111-1111-1111-111111111111',
  'vacant',
  ARRAY['https://images.unsplash.com/photo-1505691938895-1758d7feb511'],
  4,
  0,
  3500,
  'Standard fan room for 4 people. Well ventilated.'
),
(
  '33333333-3333-3333-3333-333333333332',
  '11111111-1111-1111-1111-111111111111',
  'occupied',
  ARRAY['https://images.unsplash.com/photo-1522771731474-c94fc49d2bc8'],
  2,
  2,
  5500,
  'Air-conditioned room. Currently fully occupied.'
),
(
  '33333333-3333-3333-3333-333333333333',
  '22222222-2222-2222-2222-222222222222',
  'vacant',
  ARRAY['https://images.unsplash.com/photo-1540518614846-7eded433c457'],
  3,
  1,
  4000,
  'Female only room. 2 slots available.'
) ON CONFLICT (id) DO NOTHING;

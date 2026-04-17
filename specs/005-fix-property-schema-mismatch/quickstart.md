# Quickstart: Fixed Schema and Models

Follow these steps to apply the fixes and verify functionality.

## 1. Apply Database Migration
Run the following SQL in the Supabase SQL Editor:

```sql
-- 1. Add missing images column to properties
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';

-- 2. Update view to use 'status' enum
CREATE OR REPLACE VIEW public.room_vacancies AS
SELECT 
  r.id,
  r.property_id,
  r.status,
  (r.status = 'vacant') as is_available,
  r.images as room_images,
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

-- 3. Fix RLS policies
DROP POLICY IF EXISTS "Public can view rooms of verified properties" ON public.rooms;
CREATE POLICY "Public can view rooms of verified properties" 
ON public.rooms FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.properties p 
    WHERE p.id = rooms.property_id AND p.status = 'verified'
  )
);
```

## 2. Verify Dart Model Serializers
Run `flutter test` or manually check that:
- `BookingModel.toJson()` includes `student_name`, `student_email`.
- `PropertyModel` correctly parses the `images` list from the database.

## 3. Verify Functionality
1. **Property Creation**: Add a new property with images in the owner dashboard.
2. **Booking**: Submit a booking request as a student.
3. **Deletion**: Delete a property and ensure it enters `deleted` status and storage is cleaned up.

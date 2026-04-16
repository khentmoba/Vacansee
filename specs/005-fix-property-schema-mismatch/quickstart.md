# Quickstart: fix-property-schema-mismatch

## 🚀 Setup Instructions

### 1. Update Supabase Schema
Run the following SQL in your Supabase SQL Editor:

```sql
-- 1. Create the new enum type
CREATE TYPE property_status AS ENUM ('pending', 'verified', 'deleted');

-- 2. Add the new columns to properties
ALTER TABLE public.properties 
ADD COLUMN images TEXT[] DEFAULT '{}',
ADD COLUMN status property_status DEFAULT 'pending';

-- 3. Migrate existing data (Optional if empty)
-- Map is_verified to the new status
UPDATE public.properties 
SET status = CASE WHEN is_verified THEN 'verified'::property_status ELSE 'pending'::property_status END;

-- 4. Clean up redundant columns
ALTER TABLE public.properties 
DROP COLUMN is_verified,
DROP COLUMN cover_image_url;

-- 5. Update RLS policies to handle 'deleted' status
-- Example for public SELECT
DROP POLICY IF EXISTS "Public can view verified properties" ON public.properties;
CREATE POLICY "Public can view verified properties" 
ON public.properties FOR SELECT USING (status = 'verified');
```

### 2. Update Flutter Code
1. Ensure `property_model.dart` matches the new schema (it already does).
2. Update `listing_service.dart` to use the `images` column and implement Soft Delete.
3. Update `property_service.dart` to handle the `status` enum correctly during insert/update.

### 3. Verify
1. Create a property with multiple images.
2. Delete a property and verify it remains in DB with `status = 'deleted'` but disappears from the UI.

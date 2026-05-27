-- Ensure has_vacancy column exists (may not have been added for existing databases)
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS has_vacancy BOOLEAN NOT NULL DEFAULT true;

-- Ensure monthly_price column exists (fallback safety)
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS monthly_price INTEGER NOT NULL DEFAULT 0;

-- Backfill room rows for existing properties that have total_rooms > 0
-- but no actual room records in the rooms table.

-- Step 1: Insert room rows for each property that doesn't have any
INSERT INTO public.rooms (property_id, status, capacity, monthly_rate, last_updated)
SELECT
  p.id,
  'vacant',
  1,
  p.monthly_price,
  NOW()
FROM public.properties p
WHERE p.total_rooms > 0
  AND NOT EXISTS (
    SELECT 1 FROM public.rooms r WHERE r.property_id = p.id
  );

-- Step 2: Sync the denormalized counters on the properties table
UPDATE public.properties p
SET
  total_rooms = COALESCE(room_counts.total, 0),
  available_rooms = COALESCE(room_counts.vacant, 0),
  has_vacancy = COALESCE(room_counts.vacant, 0) > 0
FROM (
  SELECT
    r.property_id,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE r.status = 'vacant') AS vacant
  FROM public.rooms r
  GROUP BY r.property_id
) room_counts
WHERE p.id = room_counts.property_id;

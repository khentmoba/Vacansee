-- Add room counts to properties table
ALTER TABLE properties ADD COLUMN IF NOT EXISTS total_rooms INTEGER DEFAULT 0;
ALTER TABLE properties ADD COLUMN IF NOT EXISTS available_rooms INTEGER DEFAULT 0;
ALTER TABLE properties ADD COLUMN IF NOT EXISTS monthly_price INTEGER DEFAULT 0;

-- Update existing records if any
UPDATE properties SET total_rooms = 0, available_rooms = 0, monthly_price = (price_range->>'min')::integer WHERE total_rooms IS NULL;

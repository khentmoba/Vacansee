-- Ratings System Migration

-- 1. Create Ratings Table
CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(booking_id) -- Ensures one rating per booking
);

-- Enable RLS
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- Ratings RLS
DROP POLICY IF EXISTS "Public can view ratings" ON public.ratings;
CREATE POLICY "Public can view ratings" 
ON public.ratings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Students can insert their own ratings" ON public.ratings;
CREATE POLICY "Students can insert their own ratings" 
ON public.ratings FOR INSERT WITH CHECK (
    auth.uid() = student_id AND
    EXISTS (SELECT 1 FROM public.bookings WHERE id = booking_id AND student_id = auth.uid())
);

DROP POLICY IF EXISTS "Students can update their own ratings" ON public.ratings;
CREATE POLICY "Students can update their own ratings" 
ON public.ratings FOR UPDATE USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can delete their own ratings" ON public.ratings;
CREATE POLICY "Students can delete their own ratings" 
ON public.ratings FOR DELETE USING (auth.uid() = student_id);

-- 2. Add Aggregation Columns to Properties
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS average_rating DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS reviews_count INTEGER DEFAULT 0;

-- 3. Trigger to Update Property Rating
CREATE OR REPLACE FUNCTION public.update_property_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DOUBLE PRECISION;
    r_count INTEGER;
BEGIN
    -- Calculate new average and count
    SELECT COALESCE(AVG(rating), 0.0), COUNT(rating)
    INTO avg_rating, r_count
    FROM public.ratings
    WHERE property_id = COALESCE(NEW.property_id, OLD.property_id);

    -- Update property
    UPDATE public.properties
    SET average_rating = avg_rating,
        reviews_count = r_count,
        last_updated = NOW()
    WHERE id = COALESCE(NEW.property_id, OLD.property_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on insert, update, delete
DROP TRIGGER IF EXISTS on_rating_change ON public.ratings;
CREATE TRIGGER on_rating_change
    AFTER INSERT OR UPDATE OF rating OR DELETE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_property_rating();

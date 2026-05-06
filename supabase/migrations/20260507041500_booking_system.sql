-- Room Booking System Migration

-- 1. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- booking_request, booking_accepted, booking_declined, booking_expired
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
ON public.notifications FOR INSERT
WITH CHECK (true); -- Usually restricted to service role or specific triggers

-- 2. Update Bookings Table (Add expires_at)
-- Assuming bookings table already exists from previous phases
ALTER TABLE IF EXISTS public.bookings 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '48 hours');

-- 3. Room Status Sync Trigger
CREATE OR REPLACE FUNCTION public.handle_booking_acceptance()
RETURNS TRIGGER AS $$
BEGIN
    -- If booking is accepted
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        -- 1. Mark room as occupied
        UPDATE public.rooms 
        SET status = 'occupied', last_updated = NOW()
        WHERE id = NEW.room_id;

        -- 2. Decline all other pending requests for the same room
        UPDATE public.bookings
        SET status = 'rejected', owner_notes = 'Room already taken', responded_at = NOW()
        WHERE room_id = NEW.room_id AND id <> NEW.id AND status = 'pending';

        -- 3. Notify student
        INSERT INTO public.notifications (user_id, title, message, type)
        VALUES (NEW.student_id, 'Booking Accepted!', 'Your booking for ' || NEW.property_name || ' has been accepted.', 'booking_accepted');
    
    ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
        -- Notify student of rejection
        INSERT INTO public.notifications (user_id, title, message, type)
        VALUES (NEW.student_id, 'Booking Declined', 'Your booking request for ' || NEW.property_name || ' was declined.', 'booking_declined');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_booking_status_change
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_booking_acceptance();

-- 4. Booking Request Notification Trigger
CREATE OR REPLACE FUNCTION public.notify_owner_on_booking()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
BEGIN
    -- Get owner_id from property
    SELECT p.owner_id INTO owner_id FROM public.properties p WHERE p.id = NEW.property_id;

    -- Notify owner
    INSERT INTO public.notifications (user_id, title, message, type)
    VALUES (owner_id, 'New Booking Request', 'You have a new booking request for ' || NEW.property_name, 'booking_request');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_booking_created
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_owner_on_booking();

-- 5. Auto-Expiration via pg_cron
-- Note: This requires the pg_cron extension to be enabled in the Supabase Dashboard
-- The following SQL is for documentation and can be run in the SQL Editor
-- SELECT cron.schedule('expire-bookings-hourly', '0 * * * *', $$
--     UPDATE public.bookings 
--     SET status = 'expired' 
--     WHERE status = 'pending' AND expires_at < NOW();
-- $$);

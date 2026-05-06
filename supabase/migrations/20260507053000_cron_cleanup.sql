-- Auto-Expiration of Pending Bookings
-- Note: Requires pg_cron extension to be enabled in the Supabase Dashboard settings

-- 1. Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 2. Schedule the hourly cleanup job
-- This job runs at the start of every hour (minute 0)
-- It updates all 'pending' bookings to 'expired' if their expiration date has passed
DO $$
BEGIN
    PERFORM cron.unschedule('expire-bookings-hourly');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END $$;

SELECT cron.schedule(
  'expire-bookings-hourly',
  '0 * * * *',
  $$
    UPDATE public.bookings 
    SET 
      status = 'expired', 
      responded_at = NOW(),
      owner_notes = COALESCE(owner_notes, 'Request expired after 48 hours without owner response.')
    WHERE 
      status = 'pending' 
      AND expires_at < NOW();
  $$
);

-- 3. Also notify students of expiration (Optional but recommended)
-- We can add another job or a trigger, but for now the cron job handles the state change.
-- The app UI will reflect the 'Expired' status.

COMMENT ON COLUMN public.bookings.expires_at IS 'The timestamp when a pending booking request becomes invalid. Default is 48 hours after request.';

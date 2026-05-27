-- Email Notifications Webhook Setup
-- Note: Requires pg_net extension and SUPABASE_SERVICE_ROLE_KEY to be set in DB settings

-- 1. Enable pg_net extension (Standard for Supabase webhooks)
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 2. Create function to trigger the Edge Function
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

-- 3. Create trigger on notifications table
DROP TRIGGER IF EXISTS on_notification_inserted ON public.notifications;
CREATE TRIGGER on_notification_inserted
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_notification_email();

COMMENT ON FUNCTION public.trigger_notification_email() IS 'Triggers the send-notification-email Edge Function via pg_net whenever a notification is created.';

-- Migration: Make booking trigger functions SECURITY DEFINER
-- 
-- These triggers run as SECURITY INVOKER by default, meaning RLS policies
-- apply to their internal queries (SELECT from properties, rooms, etc.).
-- The properties table has an admin RLS policy with a subquery on
-- public.users, which fails with "permission denied for table users"
-- when a student creates a booking.
-- 
-- Fix: Add SECURITY DEFINER and SET search_path = public so these
-- internal triggers bypass RLS, matching the pattern used by other
-- trigger functions (handle_new_user, notify_admin_on_owner_registration,
-- trigger_notification_email, update_property_rating).

-- 1. notify_owner_on_booking (fires AFTER INSERT on bookings)
CREATE OR REPLACE FUNCTION public.notify_owner_on_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    owner_id UUID;
    room_rate INTEGER;
BEGIN
    SELECT p.owner_id INTO owner_id FROM public.properties p WHERE p.id = NEW.property_id;
    SELECT r.monthly_rate INTO room_rate FROM public.rooms r WHERE r.id = NEW.room_id;

    INSERT INTO public.notifications (user_id, title, message, type, metadata)
    VALUES (
      owner_id, 
      'New Booking Request', 
      'You have a new booking request for ' || NEW.property_name || ' from ' || NEW.student_name || '.', 
      'booking_request',
      jsonb_build_object(
        'booking_id', NEW.id,
        'property_id', NEW.property_id,
        'room_id', NEW.room_id,
        'property_name', NEW.property_name,
        'room_description', NEW.room_description,
        'monthly_rate', COALESCE(room_rate, 0),
        'student_name', NEW.student_name,
        'student_email', NEW.student_email,
        'student_phone', NEW.student_phone,
        'student_notes', NEW.student_notes,
        'move_in_date', NEW.move_in_date,
        'duration_months', NEW.duration_months
      )
    );
    
    RETURN NEW;
END;
$$;

-- 2. handle_booking_acceptance (fires AFTER UPDATE on bookings)
CREATE OR REPLACE FUNCTION public.handle_booking_acceptance()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        UPDATE public.rooms 
        SET status = 'occupied', last_updated = NOW()
        WHERE id = NEW.room_id;

        UPDATE public.bookings
        SET status = 'rejected', owner_notes = 'Room already taken', responded_at = NOW()
        WHERE room_id = NEW.room_id AND id <> NEW.id AND status = 'pending';

        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
          NEW.student_id, 
          'Booking Approved!', 
          'Your booking for ' || NEW.property_name || ' has been approved.', 
          'booking_accepted',
          jsonb_build_object(
            'booking_id', NEW.id,
            'property_name', NEW.property_name,
            'room_description', NEW.room_description,
            'owner_notes', NEW.owner_notes,
            'status', NEW.status
          )
        );
    
    ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
          NEW.student_id, 
          'Booking Declined', 
          'Your booking request for ' || NEW.property_name || ' was declined.', 
          'booking_declined',
          jsonb_build_object(
            'booking_id', NEW.id,
            'property_name', NEW.property_name,
            'room_description', NEW.room_description,
            'owner_notes', NEW.owner_notes,
            'status', NEW.status
          )
        );
    END IF;
    
    RETURN NEW;
END;
$$;

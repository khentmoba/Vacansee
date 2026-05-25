-- Migration to add metadata column to public.notifications and update triggers for rich email notifications

-- 1. Add metadata column to notifications
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS metadata JSONB;

-- 2. Update notify_owner_on_booking trigger function to attach rich metadata
CREATE OR REPLACE FUNCTION public.notify_owner_on_booking()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
    room_rate INTEGER;
BEGIN
    -- Get owner_id from property
    SELECT p.owner_id INTO owner_id FROM public.properties p WHERE p.id = NEW.property_id;
    
    -- Get monthly rate from room
    SELECT r.monthly_rate INTO room_rate FROM public.rooms r WHERE r.id = NEW.room_id;

    -- Notify owner with detailed metadata
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
$$ LANGUAGE plpgsql;

-- 3. Update handle_booking_acceptance trigger function to attach metadata for approvals and declines
CREATE OR REPLACE FUNCTION public.handle_booking_acceptance()
RETURNS TRIGGER AS $$
BEGIN
    -- If booking is approved
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        -- Mark room as occupied
        UPDATE public.rooms 
        SET status = 'occupied', last_updated = NOW()
        WHERE id = NEW.room_id;

        -- Decline all other pending requests for the same room
        UPDATE public.bookings
        SET status = 'rejected', owner_notes = 'Room already taken', responded_at = NOW()
        WHERE room_id = NEW.room_id AND id <> NEW.id AND status = 'pending';

        -- Notify student with metadata
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
        -- Notify student of rejection with metadata
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
$$ LANGUAGE plpgsql;

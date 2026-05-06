# Quickstart: Room Booking System

## Prerequisites
- Supabase Project with `pg_cron` extension enabled.
- Resend API Key (for Email Notifications).

## Setup Steps

### 1. Database Schema
Run the migration in `specs/013-room-booking-system/migrations/001_booking_system.sql` (to be created) to initialize:
- `bookings` table.
- `notifications` table.
- Triggers for status synchronization.
- `pg_cron` schedule.

### 2. Edge Functions
Deploy the `booking-notifications` Edge Function:
```bash
supabase functions deploy booking-notifications --no-verify-jwt
```
Set secrets:
```bash
supabase secrets set RESEND_API_KEY=your_key
```

### 3. Flutter Integration
- Sync local models with `freezed` (`dart run build_runner build`).
- Use `BookingProvider` to listen to real-time updates.
- Add the "My Bookings" tab to the `StudentNavigation` widget.

## Testing
- **Unit**: Test `BookingService.createBooking` with mock Supabase client.
- **Widget**: Test the `BookingDialog` and `MyBookingsScreen`.
- **Integration**: Verify that accepting a booking via Owner Dashboard updates the room availability for all students.

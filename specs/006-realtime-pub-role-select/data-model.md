# Data Model: Real-time Publishing and Role Selection

## Entities

### User (public.users)
- **id**: UUID (Primary Key, matches Auth.users.id)
- **role**: user_role (ENUM: 'student', 'owner', 'deleted') - **Updated: Allows NULL initially for Google Login users.**
- **display_name**: TEXT
- **email**: TEXT
- **phone_number**: TEXT (Optional)
- **last_login_at**: TIMESTAMP WITH TIME ZONE

### Property (public.properties)
- **id**: UUID (PK)
- **status**: property_status (ENUM: 'pending', 'verified', 'deleted')
- **Real-time Enablement**: System MUST enable `REPLICA IDENTITY FULL` or standard realtime for tracking `status` changes.

### Booking (public.bookings)
- **id**: UUID (PK)
- **status**: booking_status (ENUM: 'pending', 'approved', 'rejected', 'cancelled', 'completed')
- **Real-time Enablement**: System MUST enable realtime to push status updates to the `student_id` and `owner_id`.

## State Transitions

### User Role Assignment
1. User logs in via Google → `public.users` record created (via trigger) with `role = NULL`.
2. User sees `RoleSelectionScreen`.
3. User selects 'Owner' → `UPDATE users SET role = 'owner' WHERE id = :uid`.
4. Role becomes immutable (enforced via database trigger or app logic).

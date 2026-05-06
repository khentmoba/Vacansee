# Research Report: Room Booking System

## Decision 1: Booking Expiration (48-hour)
**Decision**: Use `pg_cron` extension in Supabase to run a periodic SQL cleanup function every hour.
**Rationale**: `pg_cron` is available on the Supabase Free Tier. This allows server-side enforcement without relying on client-side logic or external cron services.
**Alternatives considered**: 
- **GitHub Actions**: More complex to set up and requires external secrets management.
- **Client-side filtering**: Risky as it doesn't actually update the database state, leading to inconsistent data reports.

## Decision 2: Notifications (In-app + Email)
**Decision**: 
- **In-app**: Use Supabase Real-time + a `notifications` table.
- **Email**: Supabase Edge Functions + Resend (Free Tier).
**Rationale**: Resend provides a generous free tier (3,000 emails/month) and integrates easily with Edge Functions.
**Alternatives considered**:
- **SendGrid/Mailchimp**: More complex APIs and stricter free tier limits for transactional emails.
- **Supabase Auth Emails**: Limited to authentication-related templates only.

## Decision 3: Gender Enforcement
**Decision**: Perform validation in both the Flutter frontend (UI-level blocking) and a Database Trigger/Constraint (Database-level integrity).
**Rationale**: Ensuring integrity at the database level prevents bypasses via direct API calls, while UI-level blocking provides immediate feedback to the user.
**Alternatives considered**:
- **Service-only validation**: Vulnerable if users bypass the service layer.

## Decision 4: Room Availability Logic
**Decision**: Automate "Occupied" status update via a `FOR EACH ROW` trigger on the `bookings` table when `status` changes to `accepted`.
**Rationale**: Centralizes business logic in the database, ensuring that any booking acceptance (regardless of source) correctly updates the room status.
**Alternatives considered**:
- **App-level logic only**: Risk of race conditions or missed updates if multiple clients are involved.

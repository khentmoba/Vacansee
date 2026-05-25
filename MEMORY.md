# System Memory & Context 🧠
<!--
AGENTS: Update this file after every major milestone, structural change, or resolved bug.
DO NOT delete historical context if it is still relevant. Compress older completed items.
-->

## 🏗️ Active Phase & Goal
**Current Task:** Phase 7 - Booking Lifecycle Actions (Check-In & Check-Out)
**Next Steps:**
1. Verify automated deployment via GitHub Actions
2. Add comprehensive widget tests for booking flows

## 📂 Architectural Decisions
*(Log specific choices made during the build here so future agents respect them)*
...
- [2026-04-17] - **Email Integration**: Deployed Supabase Edge Function `send-notification-email` using Deno and Resend API. Triggered via `pg_net` database webhooks on `public.notifications` table.
- [2026-04-17] - **Auto-Expiration Logic**: Scheduled `pg_cron` hourly job to transition 'pending' bookings to 'expired' status after 48 hours.
- [2026-05-07] - **UI Modernization**: Refactored Admin Dashboard, Owner Dashboard, and Tenant Dashboard for high-fidelity responsiveness. Implemented a floating bottom navigation bar for mobile students and a tab-based navigation for owners.
- [2026-05-07] - **Mobile Accessibility**: Optimized form layouts and booking action buttons to stack vertically on mobile to prevent layout overflows and improve touch interaction. Added adaptive bottom padding (140px) to all Tenant tabs to clear the floating bottom bar.
- [2026-05-25] - **Lease Lifecycle Flow**: Added check-in and checkout transitions for approved bookings. Checking in marks the room occupied. Checking out returns the room to vacant and sets the booking to completed.
- [2026-05-25] - **Sign-Out Route Sanitization**: Converted root `AuthWrapper` to a StatefulWidget to pop all sub-routes back to root when transitioning from authenticated to unauthenticated state. Changed top nav bar navigation from replacement named routing to popping to root to prevent stack pollution.
- [2026-05-25] - **Rich Booking Notifications**: Added `metadata` JSONB column to `notifications` table, populated by booking trigger functions. Updated Deno Edge Function to send high-fidelity HTML emails detailing booking requests, approvals, and rejections. Fixed booking screen form submission bug.
- [2026-05-25] - **UI/UX Refactoring & Visual Hierarchy**: Refactored typography hierarchies (making Login/SignUp primary H1s and Welcome subtitle), converted role selectors to segmented toggle switches, left-aligned dashboard metrics cards, unified mobile bottom navigation with higher icon contrast, and improved listings star size and spacing. Pushed to GitHub and deployed to Vercel production.
- [2026-05-25] - **Landing Page Footer Interactivity**: Replaced all 9 empty footer link buttons (Search Listings, How It Works, Safety Tips, List Your Property, Owner Resources, Pricing, About Us, Contact, Privacy Policy) with premium, responsive, interactive dialog modals containing detailed flows, custom list items, and Call to Actions linking back to the registration flow. Created full widget test suites covering all modal interaction flows.
- [2026-05-25] - **Desktop Auth Layout Scroll Fixes**: Wrapped the right-side form columns in `SingleChildScrollView` and removed layout-crashing `Spacer` widgets inside `RegisterScreen` and `LoginScreen` to ensure forms are scrollable on smaller desktop window sizes.

## 🐛 Known Issues & Quirks
...

## 📜 Completed Phases
- [x] Documentation setup (AGENTS.md, MEMORY.md, agent_docs/)
- [x] Initial scaffold
- [x] Database schema creation (schema.sql, seed.sql, Supabase migration)
- [x] Auth integration (Supabase GoTrue)
- [x] Property listing CRUD
- [x] Phase 3: Search & filtering with premium aesthetics (shimmer, glassmorphism, animations)
- [x] Phase 4a: Real-time vacancy toggle infrastructure
- [x] Phase 4b: Booking request flow with premium aesthetics and race condition protection
- [x] Phase 5a: Automated Email Notifications (Resend + Edge Functions)
- [x] Phase 5b: Self-cleaning Booking Expiration (pg_cron)
- [x] Phase 6a: UI Modernization & Premium Mobile Optimization (Responsive Dashboards)
- [x] Phase 6b: Auth Branding (Standardized Google Auth UI)
- [x] Phase 7: Booking Lifecycle Actions (Check-In & Check-Out)


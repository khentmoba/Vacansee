# System Memory & Context 🧠
<!--
AGENTS: Update this file after every major milestone, structural change, or resolved bug.
DO NOT delete historical context if it is still relevant. Compress older completed items.
-->

## 🏗️ Active Phase & Goal
**Current Task:** Phase 5 - CI/CD Stabilization & Final Schema Sync
**Next Steps:**
1. Verify automated deployment via GitHub Actions
2. Add comprehensive widget tests for booking flows

## 📂 Architectural Decisions
*(Log specific choices made during the build here so future agents respect them)*
...
- [2026-04-17] - **Email Integration**: Deployed Supabase Edge Function `send-notification-email` using Deno and Resend API. Triggered via `pg_net` database webhooks on `public.notifications` table.
- [2026-04-17] - **Auto-Expiration Logic**: Scheduled `pg_cron` hourly job to transition 'pending' bookings to 'expired' status after 48 hours.

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

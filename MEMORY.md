# System Memory & Context 🧠
<!--
AGENTS: Update this file after every major milestone, structural change, or resolved bug.
DO NOT delete historical context if it is still relevant. Compress older completed items.
-->

## 🏗️ Active Phase & Goal
**Current Task:** Phase 5 - Testing & Polish
**Next Steps:**
1. Add comprehensive widget tests for booking flows
2. Add integration tests for RLS policies
3. Performance optimization pass

## 📂 Architectural Decisions
*(Log specific choices made during the build here so future agents respect them)*
- [2025-03-25] - Chose Flutter Web + Firebase stack to leverage existing LUNA EXPRESS experience and maximize code reuse
- [2025-03-25] - Using free-tier Firebase Spark plan to maintain $0/month budget
- [2026-04-16] - **APPROVED PIVOT**: Migrated from Firebase to Supabase for relational data integrity (PostgreSQL), abandoning the NoSQL flat layout and integrating `supabase_flutter`.
- [2026-04-16] - **Real-time Vacancy**: Implemented Supabase `.stream()` subscription across all rooms for live vacancy tracking. Property cards show "Live" badges and update timestamps. Changes propagate instantly to all connected clients.
- [2026-04-16] - **Booking Flow Race Condition Prevention**: Added pre-check for room availability before creating bookings. User-friendly error message when room gets booked by another student between check and creation.
- [2026-04-16] - **Premium Booking UI**: Applied glassmorphism to property cards in booking screen, animated duration chips, shimmer loaders on MyBookings and OwnerBookings screens, hover effects with elevation lift, batch selection for owner approvals.

## 🐛 Known Issues & Quirks
*(Log current bugs or weird workarounds here)*
- Flutter Web can have slightly larger initial load times compared to pure HTML/JS, but offers superior "app-like" feel for mobile browsers

## 📜 Completed Phases
- [x] Documentation setup (AGENTS.md, MEMORY.md, agent_docs/)
- [x] Initial scaffold
- [x] Database schema creation (schema.sql, seed.sql, Supabase migration)
- [x] Auth integration (Supabase GoTrue)
- [x] Property listing CRUD
- [x] Phase 3: Search & filtering with premium aesthetics (shimmer, glassmorphism, animations)
- [x] Phase 4a: Real-time vacancy toggle infrastructure
- [x] Phase 4b: Booking request flow with premium aesthetics and race condition protection

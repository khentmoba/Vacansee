<!--
SYNC IMPACT REPORT
- Version change: 1.0.0 → 1.1.0
- List of modified principles:
  - Technical Constraints: Firebase → Supabase migration
- Added sections: N/A
- Removed sections: N/A
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: N/A
-->
# VacanSee Constitution


## Core Principles

### I. Real-time Vacancy Integrity (NON-NEGOTIABLE)
All room vacancy, availability, and preferred status data MUST be reflected in real-time. The system's primary value is providing students with up-to-the-minute accurate information. Stale data is considered a system failure.

### II. Centralized Admin Verification
To ensure a trust-based ecosystem, all property owners must be verified by a central administrator. This replaces redundant verification for each individual listing. Only verified owners can publish and manage active vacancies.

### III. Performant Simplicity
The system MUST prioritize simplicity in both architecture and user interface. Over-engineering and complex UI patterns that cause lag or high latency must be rejected. The goal is a lightning-fast experience on free-tier infrastructure.

### IV. Mobile-First Excellence
Design and interaction patterns MUST prioritize the mobile experience. University students are primary users and consume information on mobile devices first. All features must be fully functional and aesthetically premium on small screens.

### V. Type-Safe Sovereignty (No Dynamic)
No `dynamic` types are allowed in the codebase. All data models must use proper typing (Freezed/json_serializable). Business logic MUST be separated from widgets using the Service/Repository pattern to ensure testability and maintenance.

## Technical Constraints

### 0-Budget Infrastructure
The project MUST operate within the Supabase Free Tier ($0/month). Architectural decisions must optimize for relational data integrity and efficient real-time subscriptions to stay within quota.

### Flutter Web + Supabase Stack
The primary technology stack is Flutter Web for the frontend and Supabase (Auth, Database, Storage) for the backend. Any deviation requires extreme justification and a migration plan.

## Development Workflow

### Planning & Refactoring
Major changes require a plan before execution. Prefer incremental refactoring of existing functions over full rewrites. Technical debt must be addressed during feature implementation.

### Testing & Quality Gates
All new utilities must have unit tests. Core user journeys require widget tests. A `flutter analyze` pass is mandatory for all code submissions.

## Governance

This constitution supersedes all ad-hoc development decisions. Amendments require a version increment, a Sync Impact Report, and a documentation update for all dependent templates. Use `AGENTS.md` for daily agent-specific behavior guidance.

**Version**: 1.1.0 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-17

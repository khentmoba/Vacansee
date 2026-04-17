# vacansee Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-17

## Active Technologies
- Dart 3.10+ / Flutter 3.13+ (Web) + Vercel CLI (v30+), Flutter Action (Subosito) (002-github-vercel-cicd)
- N/A (Deployment targets Build artifacts in `build/web`) (002-github-vercel-cicd)
- Dart 3.10+ / Flutter 3.13+ (Web) + Vercel CLI (v30+), Subosito Flutter Action (v2) (003-fix-cicd-pipeline)
- N/A (Build artifacts only) (003-fix-cicd-pipeline)
- Dart 3.x / Flutter 3.x + `supabase_flutter`, `freezed` (003-fix-cicd-pipeline)
- Supabase (PostgreSQL) (003-fix-cicd-pipeline)
- [if applicable, e.g., PostgreSQL, CoreData, files or N/A] (003-fix-cicd-pipeline)
- Dart 3.x / Flutter 3.x + `supabase_flutter`, `provider`, `freezed` (007-fix-owner-property-deletion)
- Supabase (PostgreSQL) - `properties` table needs status/reason updates. (008-stealth-admin-access)

- [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION] (001-owner-property-management)

## Project Structure

```text
backend/
frontend/
tests/
```

## Commands

cd src; pytest; ruff check .

## Code Style

[e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]: Follow standard conventions

## Recent Changes
- 010-duplicate-email-error: Added [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]
- 008-stealth-admin-access: Added Dart 3.x / Flutter 3.x + `supabase_flutter`, `provider`, `freezed`
- 007-fix-owner-property-deletion: Added Dart 3.x / Flutter 3.x + `supabase_flutter`, `provider`, `freezed`


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->

# Implementation Plan: Fix CI/CD Pipeline

**Branch**: `003-fix-cicd-pipeline` | **Date**: 2026-04-17 | **Spec**: [specs/003-fix-cicd-pipeline/spec.md](spec.md)
**Input**: Feature specification from `/specs/003-fix-cicd-pipeline/spec.md`

## Summary

The goal is to restore the automated deployment pipeline by resolving blocking static analysis errors and fixing a nested repository conflict that hinders Git synchronization. This ensures that every push correctly triggers a Vercel build and deployment.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.13+ (Web)
**Primary Dependencies**: Vercel CLI (v30+), Subosito Flutter Action (v2)
**Storage**: N/A (Build artifacts only)
**Testing**: `flutter analyze` (Blocking gate in CI)
**Target Platform**: Web (Vercel)
**Project Type**: CI/CD Infrastructure / DevOps
**Performance Goals**: Push to Live in < 5 minutes
**Constraints**: strictly free tier ($0/month)
**Scale/Scope**: Repository-wide fix for analysis and structural integrity.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **C-001 (Integrity)**: Restoring CI automation ensures that only verified, lint-clean code reaches the production and preview environments. (PASS)
- **C-003 (Simplicity)**: Removing the nested `.git` directory simplifies the repository structure and avoids the overhead/complexity of unwanted submodules. (PASS)
- **C-005 (Type-Safety)**: Passing `flutter analyze` is a mandatory requirement for CI, which enforces strict typing and best practices across the codebase. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/003-fix-cicd-pipeline/
├── plan.md              # This file
├── research.md          # Phase 0 output: Analysis of CI failure and decisions
├── quickstart.md        # Phase 1 output: Steps to verify and push
└── tasks.md             # Phase 2 output: Actionable checklist
```

### Source Code (repository root)

```text
lib/
├── screens/
│   ├── home/owner_dashboard.dart           # Fix async context gaps
│   ├── profile/profile_screen.dart         # Fix async context gaps
│   └── property/create_property_screen.dart # Fix async context gaps

Vacansee/
└── .git/                                    # [DELETE] Remove nested repo
```

**Structure Decision**: Single project structure maintained. Standard Flutter directory layout.

## Complexity Tracking

*No violations detected. Standard best practices applied.*

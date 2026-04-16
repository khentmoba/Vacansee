# Implementation Plan: GitHub & Vercel CI/CD Integration

**Branch**: `002-github-vercel-cicd` | **Date**: 2026-04-17 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/002-github-vercel-cicd/spec.md`

## Summary

The goal is to automate the deployment lifecycle of VacanSee by synchronizing local changes with GitHub and triggering immediate builds on Vercel. This involves fixing current compiler errors to enable clean CI/CD runs, configuring GitHub Actions for reliable deployment, and ensuring Supabase environment variables are correctly injected.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.13+ (Web) 
**Primary Dependencies**: Vercel CLI (v30+), Flutter Action (Subosito)
**Storage**: N/A (Deployment targets Build artifacts in `build/web`)
**Testing**: `flutter analyze` & `flutter test` (Unit/Widget)
**Target Platform**: Web (Hosted on Vercel)
**Project Type**: DevOps / CI/CD Pipeline
**Performance Goals**: GitHub push to Vercel live URL in < 5 minutes.
**Constraints**: Operates within GitHub and Vercel free-tier limits.
**Scale/Scope**: Automated deployment for all feature branches (Previews) and `main` (Production).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **C-001 (Integrity)**: CI/CD ensures the property vacancy logic is always up-to-date across the platform. (PASS)
- **C-003 (Simplicity)**: Uses native Vercel and GitHub integrations to avoid maintenance overhead of custom CI tools. (PASS)
- **C-005 (Type-Safety)**: The deployment pipeline will be updated to enforce `flutter analyze` as a blocking gate, preventing any `dynamic` usage from reaching production. (PASS)
- **T-001 (Budget)**: Leverages GitHub Actions free minutes and Vercel's free hosting tier ($0/month). (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/002-github-vercel-cicd/
├── plan.md              # This file
├── research.md          # Phase 0 output (Technical design decisions)
├── data-model.md        # Phase 1 output (N/A for CI/CD feature)
├── quickstart.md        # Phase 1 output (Deployment instructions)
└── tasks.md             # Phase 2 output (Actionable checklist)
```

### Source Code (repository root)

```text
.github/
└── workflows/
    └── deploy.yml       # Primary GitHub Action definition

vercel.json              # Vercel deployment configuration
```

**Structure Decision**: Standard Single Project structure. No architectural changes required; only configuration files in standard project directories.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Automated Previews | Essential for CI/CD verification | Manual verification is prone to error and slow. |

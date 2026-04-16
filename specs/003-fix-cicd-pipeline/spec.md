# Feature Specification: Fix CI/CD Pipeline

**Feature Branch**: `003-fix-cicd-pipeline`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "the automatic push to git and automatic deploy to vercel for every update has gone to an error, fix it"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Restore Automated Deployment (Priority: P1)

As a developer, I want my code changes to be automatically analyzed and deployed to Vercel upon pushing to GitHub, so that the live site remains in sync with the repository.

**Why this priority**: Core value proposition of the CI/CD pipeline is automation. Currently blocked.

**Independent Test**: Push any small change to a feature branch and verify that GitHub Actions successfully completes the 'Run Analysis', 'Build Web', and 'Deploy to Vercel' steps, providing a Preview URL.

**Acceptance Scenarios**:

1. **Given** a codebase with linting issues, **When** code is pushed, **Then** GitHub Actions fails at the 'Run Analysis' step.
2. **Given** all linting issues are resolved, **When** code is pushed, **Then** GitHub Actions passes all steps and deploys to Vercel.

---

### User Story 2 - Clean Git Repository State (Priority: P2)

As a developer, I want the git repository to be in a clean state without nested git directories, so that automatic tools can stage, commit, and push without unexpected errors (e.g., Code 128).

**Why this priority**: Nested repositories cause confusion for git and CI runners, leading to partial pushes or "untracked content" warnings.

**Independent Test**: Run `git status` in the root and verify no "untracked content" or "modified: folder (untracked content)" messages appear for the `Vacansee/` directory.

**Acceptance Scenarios**:

1. **Given** a nested `.git` folder in `Vacansee/`, **When** `git add .` is run in the root, **Then** the contents of `Vacansee/` are NOT properly staged as part of the main repo.
2. **Given** the nested `.git` folder is removed, **When** `git add .` is run, **Then** all files in `Vacansee/` are correctly tracked by the main repository.

---

### Edge Cases

- **Analysis Warnings vs Errors**: The CI pipeline is currently configured to fail on *any* analysis issue. We need to decide if we should relax this or strictly adhere to zero-warning policy.
- **Git Push Conflicts**: If the remote has changes not present locally, "push" will fail.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: CI Pipeline MUST execute `flutter analyze` and pass before proceeding to build.
- **FR-002**: All existing static analysis issues (13 found) MUST be resolved.
- **FR-003**: The root repository MUST correctly track all files in the `Vacansee/` directory (resolving the nested git state).
- **FR-004**: The `deploy.yml` workflow MUST successfully trigger on pushes to any branch.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: GitHub Actions workflow completes 100% of steps (Analysis -> Build -> Deploy) for a clean push.
- **SC-002**: Zero lint/analysis issues reported by `flutter analyze`.
- **SC-003**: Vercel provides a valid Preview URL within 5 minutes of push.

## Assumptions

- No major breaking architectural changes are needed; the issues are standard linting/best-practice violations.
- The `Vacansee/` directory is intended to be part of the main repository, not a standalone submodule.
- Vercel and GitHub secrets (`VERCEL_TOKEN`, etc.) are already correctly configured (verified as previously working).

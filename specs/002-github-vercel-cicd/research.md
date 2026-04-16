# Research: GitHub & Vercel CI/CD Setup

**Feature**: GitHub & Vercel CI/CD Integration
**Status**: Decided

## Decision: Environment Variable Management
- **Decision**: Use Vercel's native Environment Variables dashboard for `SUPABASE_URL` and `SUPABASE_ANON_KEY`, rather than passing them from GitHub Secrets into the build command.
- **Rationale**: Keeps build configuration in the deployment platform (Vercel) simplified and avoids leaking secrets into build logs or command history in GitHub Actions.
- **Alternatives Considered**: 
  - Using GitHub Secrets + Vercel `--build-env` flags: Rejected as it's more complex to maintain and requires syncing two secret stores.

## Decision: Build Tooling (Vercel CLI vs Native Integration)
- **Decision**: Continue using the existing GitHub Action (`deploy.yml`) with the Vercel CLI.
- **Rationale**: Since the `.github/workflows/deploy.yml` already exists and uses the `subosito/flutter-action`, it allows for explicit control over the Flutter version and caching, which Vercel's native GitHub integration (headless) does not currently optimize for Flutter Web as deeply.
- **Alternatives Considered**: 
  - Vercel's Native GitHub Integration: Rejected because Flutter Web requires a custom build environment (Flutter SDK) that is easier to manage via GitHub Actions.

## Decision: CI/CD Quality Gates
- **Decision**: Add `flutter analyze` and `flutter test` as blocking steps before the build and deploy steps.
- **Rationale**: Enforces the project's **Constitution Principle V (Type-Safe Sovereignty)** by ensuring no code with `dynamic` or compilation errors hits the deployment stage.

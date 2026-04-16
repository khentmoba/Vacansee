# Research: CI/CD Pipeline Failure

## Technical Overview
The CI/CD pipeline is currently non-functional due to two distinct failures:
1.  **Static Analysis Blocking**: The `deploy.yml` workflow enforces a clean `flutter analyze` run. Currently, 13 issues are reported (info/warning level but blocking the CI script).
2.  **Git Repository Corruption**: The existence of a nested `.git` directory in `Vacansee/` prevents standard git operations from tracking changes correctly, causing "Code 128" errors on GitHub and "untracked content" locally.

## Decisions

### Decision: Analysis Issue Resolution
**Resolution**: Apply `use_build_context_synchronously` fixes across all affected screens.
- **Rationale**: This is the standard Flutter best practice for handling async gaps. Using `if (!context.mounted) return;` or capturing state into local variables before the first await ensures safety.
- **Alternatives considered**: 
  - Relaxing CI rules (rejected): We want to maintain high code quality as per Project Constitution (C-005).
  - Ignoring specific lints (rejected): The issues point to potential runtime crashes if a widget is unmounted before an async operation completes.

### Decision: Git Structure Restoration
**Resolution**: Delete `c:/APPLICATIONS/vacansee/Vacansee/.git` folder.
- **Rationale**: The `Vacansee/` folder seems to contain documentation and part labels that are part of the main project. Having a nested `.git` folder (a "git subrepo") without a submodule configuration breaks the main repo's ability to stage these files.
- **Alternatives considered**: 
  - Configuring as a Submodule (rejected): Overly complex for documentation folders.
  - Moving the folder out of the repo (rejected): Breaks the logical grouping of project materials.

## Findings

### Flutter Analyze Detailed Issues
- `lib/screens/home/owner_dashboard.dart`: Multiple async gaps in action handlers.
- `lib/screens/profile/profile_screen.dart`: Async gap in profile update/signout.
- `lib/screens/property/create_property_screen.dart`: Async gap in property creation/image upload.

### Git State
- `git status` reports `modified: Vacansee (untracked content)`.
- Verified `Vacansee/.git` is a directory.

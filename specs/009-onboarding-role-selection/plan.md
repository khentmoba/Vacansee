# Implementation Plan: Onboarding Role Selection

**Branch**: `010-onboarding-role-selection` | **Date**: 2026-04-17 | **Spec**: [spec.md](file:///c:/APPLICATIONS/vacansee/specs/009-onboarding-role-selection/spec.md)
**Input**: Feature specification from `/specs/009-onboarding-role-selection/spec.md`

## Summary
Implement a mandatory onboarding flow for users logging in via external providers (Google) to select their role (Student or Owner) and provide mandatory contact information (Name, Phone). This includes updating the `public.users` schema, enhancing the `AuthProvider` logic, and creating a premium role selection interface with admin notification logic for owner registrations.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: Supabase Flutter SDK, Provider, flutter_dotenv  
**Storage**: PostgreSQL (Supabase)  
**Testing**: flutter test (Unit & Widget)  
**Target Platform**: Flutter Web (Primary), Mobile (Secondary/Responsive)
**Project Type**: Mobile-first Web Application  
**Performance Goals**: Onboarding screen load < 500ms; Submission < 1s  
**Constraints**: Supabase Free Tier quotas; Strict Type Safety (No `dynamic`)  
**Scale/Scope**: Mandatory for all new users; 2-step form (Role -> Info)

## Constitution Check

| Principle | Check | Status |
| :--- | :--- | :--- |
| **I. Real-time Vacancy Integrity** | Ensures users have correct roles before interacting with real-time data. | ✅ PASS |
| **II. Centralized Admin Verification** | Implements 'is_verified' gate and admin notification for owners. | ✅ PASS |
| **III. Performant Simplicity** | Uses native Supabase triggers for notifications to minimize client logic. | ✅ PASS |
| **IV. Mobile-First Excellence** | Responsive Role Selection UI tailored for mobile students. | ✅ PASS |
| **V. Type-Safe Sovereignty** | Updates `UserModel` and `AuthProvider` with strict Dart types. | ✅ PASS |

## Project Structure

### Documentation (this feature)

```text
specs/009-onboarding-role-selection/
├── plan.md              # Implementation strategy
├── research.md          # Technology decisions & exploration findings
├── data-model.md        # Database schema & entity definitions
├── quickstart.md        # Developer setup & verification steps
├── contracts/           # UI/Service interface definitions
└── tasks.md             # Actionable task list (Phase 2 output)
```

### Source Code (repository root)

```text
lib/
├── models/
│   └── user_model.dart             # Update isVerified and copyWith
├── providers/
│   └── auth_provider.dart          # Update setUserRole to handle full profile
├── services/
│   └── auth_service.dart           # Update updateProfile logic
├── screens/
│   └── auth/
│       └── role_selection_screen.dart # Implement form and selection UI
├── widgets/
│   └── common/
│       └── phone_field.dart        # [NEW] Reusable phone input with validation
```

**Structure Decision**: Following existing feature-based folder organization. Logic resides in `providers/` and `services/`, with UI in `screens/`.

## Complexity Tracking

*No constitution violations identified. Implementation follows standard architectural patterns.*

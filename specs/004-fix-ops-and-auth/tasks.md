# Tasks: Fix Ops & Auth Enhancement

**Input**: [spec.md](file:///c:/APPLICATIONS/vacansee/specs/004-fix-ops-and-auth/spec.md), [implementation_plan.md](file:///C:/Users/Admin/.gemini/antigravity/brain/93950b01-c478-4ee1-b4ea-1247552a14ef/implementation_plan.md)
**Prerequisites**: plan.md (approved), spec.md (clarified)

## Phase 1: Setup
**Purpose**: Environment preparation

- [x] T001 Run `flutter pub get` to ensure environment is synced

---

## Phase 2: Foundational (Blocking Prerequisites)
**Purpose**: Domain standardization across all platforms

**⚠️ CRITICAL**: Standardizing the domain is required for correct auth redirects

- [x] T002 Update domain to `vacansee-xi.vercel.app` in `lib/services/auth_service.dart`
- [x] T003 [P] Update domain references and metadata in `web/index.html`

**Checkpoint**: Foundation ready - Domain-sensitive operations (Auth, Deletes) can proceed.

---

## Phase 3: User Story 1 - Secure Property Deletion (Priority: P1) 🎯 MVP
**Goal**: Harden the listing deletion flow and ensure atomic DB cleanup

- [ ] T004 [P] [US1] Refactor `ListingService.deletePropertyListing` in `lib/services/listing_service.dart` with robust URL parsing
- [ ] T005 [US1] Implement atomicity in `deletePropertyListing` to prevent storage errors from blocking DB deletion
- [ ] T006 [P] [US1] Add cleanup failure logging to `ListingService`

**Checkpoint**: Property deletion is functional and robust.

---

## Phase 4: User Story 3 - Unified Identity (Priority: P1) [DONE]
**Goal**: Enable seamless account linking for Google Authentication

- [x] T007 [P] [US3] Enhance `signInWithGoogle` in `lib/services/auth_service.dart` for account identification
- [x] T008 [US3] Update `register` logic in `lib/services/auth_service.dart` to handle email conflicts gracefully
- [x] T009 [US3] Update `AuthProvider` in `lib/providers/auth_provider.dart` state listener for identity refresh

**Checkpoint**: Identity merging complete.

---

## Phase 5: Polish & Verification
- [x] T010 Run `flutter analyze` to verify code type safety and quality
- [x] T011 [Verification] Manually verify Property deletion (DB + Storage cleanup)
- [x] T012 [Verification] Manually verify Google Account linking flow

---

## Dependencies & Execution Order
1. **Phase 1 & 2** are strictly foundational.
2. **Phase 3 & 4** can run in parallel.
3. **Phase 5** is final verification.

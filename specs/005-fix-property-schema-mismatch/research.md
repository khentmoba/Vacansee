# Research: Property Schema Alignment & Deletion Fix

## Decision 1: Database Schema Migration
- **Decision**: Update `properties` table to include `images` (TEXT[]) and `status` (property_status enum).
- **Rationale**: `PropertyModel` already expects these fields. Aligning the DB prevents `PostgrestException` and ensures type safety.
- **Alternatives Considered**: 
    - mapping `images` to `cover_image_url` (Rejected: Model and UI expect a list, mapping is complex).
    - using `JSONB` for images (Rejected: `TEXT[]` is more standard in Postgres for simple string lists).

## Decision 2: Field Redundancy
- **Decision**: Drop `cover_image_url` and `is_verified` from the `properties` table.
- **Rationale**: `cover_image_url` is derivable from `images.first`. `is_verified` is superseded by the `status` enum ('verified').
- **Alternatives Considered**:
    - Keep columns as backups (Rejected: Adds maintenance overhead and risks out-of-sync state).

## Decision 3: Deletion Implementation
- **Decision**: Implement **Soft Delete** by updating `status` to 'deleted'. Update RLS policies to exclude 'deleted' rows from public SELECT.
- **Rationale**: Matches `PropertyModel`'s `deleted` status and provides a reversible state for accidental deletions.
- **Alternatives Considered**: 
    - Hard Delete (Rejected: User requested "delete is not working", and soft delete is a more robust pattern for this scale).

## Decision 4: Real-time Vacancy Calculation
- **Decision**: Keep `has_vacancy` in the `PropertyModel` but calculate it on-the-fly via the `room_vacancies` view or filtered room streams.
- **Rationale**: Storing it in the `properties` table would require triggers or complex sync logic. Calculating it ensures the "Real-time Vacancy Integrity" principle.

## Technical Unknowns Resolved:
- **Supabase Enum**: Postgres allows `CREATE TYPE property_status AS ENUM (...)`.
- **Soft Delete RLS**: Can be handled by adding `AND status != 'deleted'` to SELECT policies.

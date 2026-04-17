# Research: Schema and Model Mismatches

## Findings

### Decision 1: Booking Model Serialization
- **Issue**: `BookingModel.toJson()` currently omits `student_name`, `student_email`, and `student_phone`. The database has a `NOT NULL` constraint on `student_name` and `student_email`.
- **Solution**: Explicitly add these fields to the `toJson()` map. Since they are required in the constructor and existing in the class, this is a straightforward mapping fix.
- **Rationale**: Ensures compliance with the database schema without needing to change constraints.

### Decision 2: Property Table "images" Column
- **Issue**: The application code expects an `images` column of type `TEXT[]`, but it's missing from the physical database (confirmed by `PostgrestException`).
- **Solution**: Execute an `ALTER TABLE` statement to add the column with a default empty array `{}`.
- **Rationale**: Restores functionality for property creation and image storage synchronization.

### Decision 3: Schema Standardization (status vs is_verified)
- **Issue**: `schema.sql` uses `is_verified` (boolean) in views and RLS policies, but the `properties` table uses a `status` enum (`pending`, `verified`, `deleted`).
- **Solution**: Standardize on `status = 'verified'` for all logic. Remove all references to `is_verified`.
- **Rationale**: Aligns the database logic with the Dart `PropertyModel` and prevents "column not found" errors in views.

### Decision 4: Soft Delete Implementation
- **Issue**: Spec requires reliable deletion. Service already has a soft delete implementation but it was failing due to the missing `images` column.
- **Solution**: Continue using soft delete (setting `status` to `deleted`). Ensure associated images in Supabase Storage are removed during this process.
- **Rationale**: Safer for data integrity and consistent with university record-keeping needs.

## Alternatives Considered
- **Hard Delete**: Rejected because soft deletion allows for status-based filtering while keeping data for audits/logs.
- **Adding is_verified Boolean**: Rejected to avoid redundancy and keep the schema clean (normalized to the enum).

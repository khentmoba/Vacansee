# Research: Owner Property Management

## Decisions

### Storage Cleanup
- **Decision**: Use batch deletion via `supabase.storage.from(bucket).remove(list_of_paths)`.
- **Rationale**: Efficiently removes all property images in a single request. Necessary for staying within Supabase Free Tier limits (Principle III).
- **Alternatives considered**: Single file deletions (rejected due to excessive API calls and complexity).

### Database Security (RLS)
- **Decision**: Implement `FOR UPDATE` and `FOR DELETE` policies on the `properties` and `rooms` tables using `auth.uid() = owner_id`.
- **Rationale**: Ensures that only the authenticated owner can modify their listings, fulfilling security requirements (Principle II).
- **Alternatives considered**: Client-side validation only (rejected as insecure).

### Form Management & Pre-population
- **Decision**: Use a `StatefulWidget` to manage a local clone of the `Property` and `Room` list. Pre-populate UI fields using the existing model data.
- **Rationale**: Allows the user to make multiple changes and "Cancel" easily without affecting the live state until "Save" is clicked.
- **Alternatives considered**: Direct live updates (rejected as it breaks "Cancel" functionality and could cause race conditions).

### Room Management in Edit Flow
- **Decision**: Provide an inline interface to add/edit/remove rooms within the property edit screen.
- **Rationale**: Fulfills the "Full Lifecycle" requirement from clarification sessions.

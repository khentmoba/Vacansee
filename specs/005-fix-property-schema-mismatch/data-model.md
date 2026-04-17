# Data Model: Schema Fixes

## Entities

### Property (Standardized)
Represents a boarding house listing.

| Field | Type | DB Column | Note |
|-------|------|-----------|------|
| id | UUID | `id` | Primary Key |
| ownerId | UUID | `owner_id` | References `users.id` |
| name | String | `name` | |
| address | String | `address` | |
| status | Enum | `status` | `pending`, `verified`, `deleted` |
| images | List<String> | `images` | **NEW** (TEXT[]) |
| lastUpdated | DateTime | `last_updated` | |

### Booking (Fixed)
Represents a room booking request.

| Field | Type | DB Column | Note |
|-------|------|-----------|------|
| id | UUID | `id` | Primary Key |
| studentId | UUID | `student_id` | References `users.id` |
| propertyId | UUID | `property_id` | References `properties.id` |
| roomId | UUID | `room_id` | References `rooms.id` |
| studentName | String | `student_name` | **CRITICAL**: Must be sent in `toJson()` |
| studentEmail | String | `student_email` | **CRITICAL**: Must be sent in `toJson()` |
| studentPhone | String? | `student_phone` | |
| status | Enum | `status` | `pending`, `approved`, etc. |

## Relationships

- `Booking` belongs to `User` (student), `Property`, and `Room`.
- `Property` belongs to `User` (owner).
- `Room` belongs to `Property`.

## State Transitions

### Property Status
1. `pending`: Initial state upon creation.
2. `verified`: Set by admin after checking requirements.
3. `deleted`: Soft-delete state. Listing hidden from search.

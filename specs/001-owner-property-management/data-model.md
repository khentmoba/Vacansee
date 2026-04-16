# Data Model: Owner Property Management

## Entities

### Property
Represents the main listing entry managed by the owner.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary Key |
| owner_id | UUID | Reference to `auth.users` |
| name | String | Display name of the property |
| address | String | Full physical address. Modification triggers re-verification. |
| status | Enum | `verified`, `pending`, `deleted` |
| images | List<String> | List of storage paths for property images |
| created_at | DateTime | Timestamp of creation |
| updated_at | DateTime | Timestamp of last edit |

### Room
Represents individual availability units within a property.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary Key |
| property_id | UUID | Foreign Key to `Property.id` (Cascade delete enabled) |
| type | String | Room type (e.g., "Single Player", "Double Sharing") |
| vacancy_count | Integer | Number of available spots in this room type |
| price | Double | Monthly rent for this room type |
| gender_preference | Enum | `male`, `female`, `mixed` |

## Relationships
- **Property (1) <-> Rooms (N)**: A property can have multiple room types.
- **Owner (1) <-> Property (N)**: An owner can manage multiple properties.

## Database Rules (RLS)

### `properties` Table
- `SELECT`: `true` (Publicly viewable)
- `INSERT`: `auth.uid() = owner_id`
- `UPDATE`: `auth.uid() = owner_id`
- `DELETE`: `auth.uid() = owner_id`

### `rooms` Table
- Allied with property ownership. Cascade deletes from `properties` will handle most cases, but direct edits require `auth.uid() = (SELECT owner_id FROM properties WHERE id = property_id)`.

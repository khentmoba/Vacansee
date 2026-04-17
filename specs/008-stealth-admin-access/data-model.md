# Data Model: Stealth Admin Access

## Database Schema (PostgreSQL)

### Enum Updates
```sql
ALTER TYPE property_status ADD VALUE IF NOT EXISTS 'rejected';
```

### Table Updates: `public.properties`
| Column | Type | Description |
|--------|------|-------------|
| status | property_status | Updated to include 'rejected' |
| rejection_reason | TEXT | [NEW] Stored feedback for rejected listings |

## Application Models (Dart)

### `PropertyStatus` (Enum)
- `pending`
- `verified`
- `rejected` [NEW]
- `deleted`

### `PropertyModel` (Freezed)
| Field | Type | Note |
|-------|------|------|
| status | PropertyStatus | Defaults to `pending` |
| rejectionReason | String? | [NEW] Mapped from `rejection_reason` |

## State Transitions

| From | To | Trigger | Actor |
|------|----|---------|-------|
| pending | verified | Verify Action | Admin |
| pending | rejected | Reject Action (+ reason) | Admin |
| rejected | pending | Update Action (Edit) | Owner |
| verified | rejected | Unverify/Reject Action | Admin |

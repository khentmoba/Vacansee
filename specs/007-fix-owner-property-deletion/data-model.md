# Data Model: Owner Property Deletion

## Entities

### Property (Updated)
- **Status Enum**: Existing `property_status` ('pending', 'verified', 'deleted').
- **Status transition**: `verified -> deleted` (Owner initiated).

### Room (Updated)
- **Status Enum**: Existing `room_status` ('vacant', 'occupied', 'maintenance').
- **Sync Rule**: On property status change to `deleted`, all associated rooms MUST transition to `maintenance`.

### Booking (Static)
- **Reference**: Properties cannot be `deleted` without a warning if bookings in `pending` or `approved` state exist.

## State Transitions

| Entity | Current Status | Event | Target Status |
|--------|----------------|-------|---------------|
| Property | verified/pending | Owner Delete | deleted |
| Room | any | Property Deleted | maintenance |
| Property | deleted | Owner Undo | verified (or previous) |
| Room | maintenance | Property Undo | vacant (standard default) |

## Validation Rules
- **Active Booking Check**: `count(bookings where property_id = X and status in (pending, approved)) > 0` triggers warning.
- **Ownership**: `properties.owner_id == auth.uid()` mandatory for deletion update.

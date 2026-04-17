# Service Contract: Property Moderation

## `PropertyService`

### `moderateProperty`
Updates the status of a property and records a rejection reason if applicable.

**Signature**:
```dart
Future<void> moderateProperty({
  required String propertyId,
  required PropertyStatus status,
  String? reason,
})
```

**Pre-conditions**:
- `propertyId` must exist in `properties` table.
- Caller must have `admin` role (enforced at RLS level).
- If `status == PropertyStatus.rejected`, `reason` SHOULD be provided.

**Post-conditions**:
- `properties[propertyId].status` is updated.
- `properties[propertyId].rejection_reason` is updated.
- `properties[propertyId].last_updated` is set to `now()`.

## `AuthProvider`

### `isAdmin`
Helper getter for UI branching.

**Signature**:
```dart
bool get isAdmin => _user?.role == UserRole.admin;
```

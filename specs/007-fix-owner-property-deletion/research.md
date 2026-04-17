# Research: Owner Property Deletion Fix

## Deletion Policy & Integrity

### Decision: Soft-delete with Room Synchronization
**Rationale**: 
- **Integrity**: Deleting a property while bookings exist causes UI orphaned cards or errors if referential integrity is not strictly CASCADE. 
- **Audit**: Soft-delete preserves historical data for analytics and dispute resolution.
- **Vacancy**: Rooms must be marked as 'maintenance' to prevent them from showing up in any global vacancy streams that might not filter by the property's parent status.

### Alternatives Considered:
- **Hard Delete**: Rejected because it breaks booking history and complicates storage cleanup if foreign keys are not handled perfectly.
- **Sync to Occupied**: Rejected because 'occupied' implies revenue/tenants; 'maintenance' correctly reflects that the listing is "offline".

## Technical Implementation Details

### 1. Active Booking Detection
**Query**:
```dart
final bookings = await _supabase
    .from('bookings')
    .select('id')
    .eq('property_id', propertyId)
    .inFilter('status', ['pending', 'approved']);
```
**Decision**: Check this before showing the second confirmation dialog.

### 2. Bulk Room Update
**Query**:
```dart
await _supabase
    .from('rooms')
    .update({'status': 'maintenance'})
    .eq('property_id', propertyId);
```
**Decision**: Include this in `ListingService.deletePropertyListing`.

### 3. Undo/Restore Mechanism
**Internal State**: The `PropertyProvider` will temporarily remove the property from its list but keep a reference. If the SnackBar "Undo" is clicked, it will call an `undoDelete` service method that reverts the status.
**Timeout**: 5 seconds.

## Best Practices for Flutter Web + Supabase
- **Streams**: Use `.filter()` on the stream if possible, or `list.where()` in the provider to avoid over-fetching.
- **RLS**: Ensure owners have `UPDATE` permission on both `properties` and `rooms`.

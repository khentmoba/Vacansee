# ListingService Contract: Property Deletion

## Methods

### `deletePropertyListing(String propertyId)`
- **Purpose**: Performs a soft-delete of a property, synchronizes its rooms, and triggers storage cleanup.
- **Side Effects**:
    - Updates `properties` table row to `status: 'deleted'`.
    - Updates `rooms` table rows for `property_id` to `status: 'maintenance'`.
    - (Background) Removes associated images from `property_images` bucket.

### `hasActiveBookings(String propertyId)`
- **Purpose**: Checks for non-terminal bookings.
- **Returns**: `Future<bool>` - `true` if any 'pending' or 'approved' bookings exist.

### `restorePropertyListing(String propertyId)`
- **Purpose**: Reverts a soft-delete.
- **Side Effects**:
    - Updates `properties` table row back to `status: 'verified'` (or 'pending' if applicable).
    - Optional: Updates `rooms` back to `vacant` (Manual reactivation is safer but spec implies "Undo" should restore functionality).

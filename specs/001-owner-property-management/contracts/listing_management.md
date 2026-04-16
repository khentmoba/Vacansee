# Service Contract: Listing Management

## Overview
Defines the programmatic interface for property owners to manage their listings.

## Methods

### `updatePropertyListing`
Updates an existing property and its associated rooms in a single transaction if possible.

**Parameters**:
- `property`: `Property` object (contains updated metadata)
- `rooms`: `List<Room>` (contains current list of rooms for this property)
- `deletedRoomIds`: `List<String>` (IDs of rooms that were removed during edit)
- `deletedImagePaths`: `List<String>` (Storage paths for images removed during edit)

**Logic**:
1. If `property.address` changed, set `status` to `pending`.
2. Update `property` record in Supabase.
3. Delete rooms in `deletedRoomIds`.
4. Upsert `rooms` (Insert new, Update existing).
5. Delete images in `deletedImagePaths` from Storage.
6. Broadcast changes via Realtime.

---

### `deletePropertyListing`
Permanently removes a property and all associated assets.

**Parameters**:
- `propertyId`: `String` (ID of property to delete)

**Logic**:
1. Fetch all room records for the property.
2. Fetch `images` list from the property record.
3. Delete all rooms from the database (cascade delete should handle this if configured).
4. Delete all images from Supabase Storage.
5. Delete the property record.
6. Trigger UI navigation back to Dashboard.

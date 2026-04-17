# Quickstart: Testing Property Deletion

## Verification Workflow

1. **Login as Owner**: Use an owner account with existing listings.
2. **Identify Property**: Choose a property to delete (ensure it has at least one room).
3. **Trigger Deletion**: Click the "Delete" icon on the property card in the Owner Dashboard.
4. **Active Booking Warning (Optional)**:
    - Create a pending booking for this property from a student account.
    - Click "Delete" again.
    - Verify that a warning message about active bookings appears before the final confirmation.
5. **Confirm Deletion**: Accept the confirmation dialog.
6. **Verify Dashboard Refresh**:
    - The property should immediately disappear from the "My Boarding Houses" grid.
    - The "Total Listings" count should decrease.
7. **Verify Undo**:
    - Click the "Undo" button in the SnackBar that appeared after deletion.
    - Verify the property reappears in the grid and the count increases back.
8. **Backend Verification (Supabase Dashboard)**:
    - Check the `properties` table: status should be `deleted`.
    - Check the `rooms` table: all associated rooms should have status `maintenance`.

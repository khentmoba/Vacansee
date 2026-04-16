# Quickstart: Testing Owner Property Management

## Prerequisites
- Authenticated user with "Owner" permissions.
- At least one existing property listing in Supabase.

## Manual Verification Steps

### 1. Verification of "Edit" Flow
1. Log in as an owner.
2. Navigate to the **Owner Dashboard**.
3. Locate an existing listing and click **Edit**.
4. Change the **Monthly Price** and update one **Room Type** name.
5. Click **Save**.
6. **Expectation**: Redirect to Dashboard. A "Success" notification appears. Real-time updates reflect changes in a separate student-view browser tab.

### 2. Verification of "Delete" Flow
1. Click **Delete** on a listing.
2. Verify the **Confirmation Dialog** appears.
3. Click **Confirm**.
4. **Expectation**: Redirect to Dashboard. Listing is gone. Verify in Supabase dashboard that the database records (Property + Rooms) and Storage images are purged.

### 3. Verification of "Address Change" Re-verification
1. Edit a **Verified** listing.
2. Change the **Address** field.
3. Click **Save**.
4. **Expectation**: Listing status changes to `Pending`. Admin Dashboard (if exists) shows re-verification required.

## Automated Tests (Draft)
- Unit test for `ListingManagement.updatePropertyListing` handling address change logic.
- Widget test for `PropertyEditForm` pre-population.
- Integration test for cascades upon deletion.

# Quickstart: Real-time Publishing and Role Selection

## 1. Local Setup
Ensure you have the latest code and environment variables:
```bash
flutter pub get
```

## 2. Supabase Realtime Configuration
Execute the following SQL in the Supabase SQL Editor to ensure realtime is enabled for the required tables:
```sql
-- Enable Realtime for properties and bookings
ALTER PUBLICATION supabase_realtime ADD TABLE properties;
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE rooms;
```

## 3. Manual Verification Steps

### A. Role Selection
1. Open the app and sign in with a **new Google account**.
2. Verify you are presented with the **Role Selection** screen.
3. Try to navigate away (e.g., refreshing or changing URL); verify you are blocked until a choice is made.
4. Select "Student" and verify you are taken to the student exploration screen.

### B. Real-time Publishing
1. Open two browser windows:
   - Window 1: Signed in as a **Student** on the "Explore" screen.
   - Window 2: Signed in as an **Owner** on the dashboard.
2. In Window 2, publish a new property.
3. Verify that in Window 1, the new property appears **instantly** without a page refresh.

### C. Real-time Booking
1. In Window 1 (Student), select a room and click "Book".
2. In Window 2 (Owner), verify the "Pending Bookings" notification/count updates **instantly**.
3. In Window 2, approve the booking.
4. In Window 1, verify the booking status changes to "Approved" in the UI **instantly**.

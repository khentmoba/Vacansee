# Quickstart: Testing UI Improvements

## Running the Application

To test the mobile-responsive layouts and web compact tables:

1. **Web (Desktop view for compact tables and header tabs):**
   ```bash
   flutter run -d chrome
   ```
   *Resize the browser window to see how tables maintain a max-width and horizontal scrolling.*

2. **Mobile (Mobile view for widget alignment and text truncation):**
   ```bash
   flutter run -d chrome --web-browser-flag="--window-size=375,812"
   ```
   *Observe the alignment of widgets in the Admin Dashboard and the ellipsis truncation of long text.*

## Verification Steps

1. Navigate to any screen with header tabs (e.g., Admin Dashboard, Property List). Click between tabs and verify the text does not shift vertically.
2. Go to the Admin Dashboard on a mobile viewport and verify all widgets are perfectly aligned with consistent padding.
3. Access the Admin Profile and verify the permissions list is displayed as a simple checklist.

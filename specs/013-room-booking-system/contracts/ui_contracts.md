# UI Contracts: Room Booking System

## Components

### BookingDialog
- **Input**: `RoomModel room`, `PropertyModel property`.
- **Action**: `BookingService.createBooking`.
- **States**: `Idle`, `Submitting`, `Success`, `Error`.
- **Interaction**: Student clicks "Book Now", confirms via a simple modal, receives success/error feedback.

### MyBookingsScreen (Student)
- **Data Source**: `BookingService.getStudentBookings`.
- **Features**:
  - List of bookings sorted by date.
  - Status indicators (Pending, Accepted, etc.).
  - "Cancel Request" button for pending bookings.
  - "Contact Owner" shortcut (Email/Phone) for accepted bookings.

### OwnerBookingDashboard (Owner)
- **Data Source**: `BookingService.getOwnerBookings`.
- **Features**:
  - Grouping by Property/Room.
  - Quick "Accept" / "Decline" buttons.
  - Optional message input on "Decline".
  - Real-time notification badge for new requests.

## Service Contracts

### BookingService
- `Stream<List<BookingModel>> watchBookings(String userId, {required bool isOwner})`
- `Future<void> createRequest(String studentId, String roomId)`
- `Future<void> processRequest(String bookingId, BookingStatus newStatus, {String? notes})`

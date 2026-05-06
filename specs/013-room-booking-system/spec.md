# Feature Specification: Room Booking System

**Feature Branch**: `013-room-booking-system`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "i want the booking feature to work, like a student books for the room and there needs to be a way for the owner to receive the booking and accept it and ofcourse it automatically detects in the system and makes the room occupied and wont be available"

## Clarifications

### Session 2026-05-07
- Q: Aside from the room selection, what specific information must a student provide in the booking request? → A: Generic Request (Student just clicks "Book" and the request is sent with their profile info).
- Q: Should the system strictly enforce gender-based room assignments during the booking process? → A: Automated Enforcement (Prevent students from booking if their profile gender doesn't match the property/room's gender orientation).
- Q: Where should students manage their active booking requests? → A: "My Bookings" Tab (A centralized dashboard view for students to track all their active and past requests).
- Q: When a room is accepted for one student, should the system automatically "Decline" all other pending requests for that same room? → A: Auto-Decline (Automatically decline all other pending requests for the same room once one is accepted).
- Q: When an owner declines a booking, should they be required to provide a reason? → A: Optional Reason (Owners can provide a reason from a preset list or a custom text field).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Student Booking Request (Priority: P1)

As a student, I want to book a room so that I can secure my accommodation for the upcoming semester.

**Why this priority**: This is the core entry point for the booking feature. Without the ability to request a booking, the rest of the workflow cannot proceed.

**Independent Test**: Can be fully tested by a student selecting an available room and submitting a booking request, which then appears in the system as "pending".

**Acceptance Scenarios**:

1. **Given** a student is logged in and viewing an available room, **When** they click "Book Now" and confirm, **Then** a booking request is created with a "pending" status.
2. **Given** a room already has a "pending" or "accepted" booking from the same student, **When** they try to book again, **Then** the system should prevent duplicate requests.

---

### User Story 2 - Owner Booking Approval (Priority: P1)

As a property owner, I want to receive and review booking requests so that I can accept or decline potential tenants.

**Why this priority**: This is the decision-making step that completes the booking process and triggers the availability update.

**Independent Test**: Can be fully tested by an owner viewing a list of pending bookings for their property and clicking "Accept" on one.

**Acceptance Scenarios**:

1. **Given** an owner has pending booking requests, **When** they view their dashboard, **Then** they see a list of student names and requested rooms.
2. **Given** a pending booking request, **When** the owner clicks "Accept", **Then** the booking status changes to "accepted" and the student is notified.

---

### User Story 3 - Automated Room Status Update (Priority: P1)

As the system, I want to automatically mark a room as occupied once a booking is accepted so that other students cannot book the same room.

**Why this priority**: This fulfills the core value proposition of real-time vacancy tracking and prevents overbooking.

**Independent Test**: Can be fully tested by verifying that after an owner accepts a booking, the room's status in the database and UI changes to "Occupied" or "Unavailable".

**Acceptance Scenarios**:

1. **Given** an owner has just accepted a booking for Room A, **When** the system processes the acceptance, **Then** Room A's availability status is updated to "Occupied".
2. **Given** a room is marked as "Occupied", **When** a student searches for available rooms, **Then** this room should either be hidden or shown as unavailable for booking.

---

### Edge Cases

- **Concurrent Requests**: When one booking request is accepted, the system MUST automatically decline all other pending requests for the same room and notify those students.
- **Owner Inactivity**: Booking requests automatically expire and are cancelled after 48 hours of inactivity from the owner.
- **Room Deletion**: What happens to pending bookings if an owner deletes a room or property? (System should cancel pending bookings and notify students).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow students to submit booking requests for rooms marked as "Available".
- **FR-002**: System MUST provide a dashboard for owners to view, accept, and decline booking requests.
- **FR-003**: System MUST automatically update a room's status to "Occupied" immediately upon booking acceptance.
- **FR-004**: System MUST prevent students from booking rooms that are already "Occupied".
- **FR-005**: System MUST notify students via In-app notifications and Email when their booking request is accepted or declined.
- **FR-006**: System MUST persist booking history for both students and owners.
- **FR-007**: Booking requests MUST be "one-tap" (generic); the system uses the student's existing profile information without requiring additional input fields.
- **FR-008**: System MUST automatically enforce gender orientation policies, preventing students from booking rooms that do not match their profile gender.
- **FR-009**: System MUST provide a "My Bookings" section for students to track the status of their submitted requests.
- **FR-010**: System MUST automatically decline all other pending requests for a room once a booking for that room is accepted.
- **FR-011**: Owners SHOULD be able to provide an optional reason when declining a booking request.

### Key Entities *(include if feature involves data)*

- **Booking**: Represents a reservation request. Key attributes: `id`, `student_id`, `room_id`, `status` (pending, accepted, declined, cancelled), `created_at`.
- **Room**: Existing entity, needs to support status updates (Available, Occupied).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can complete a booking request in under 30 seconds.
- **SC-002**: Owners can process a booking request (accept/decline) with a single click from their dashboard.
- **SC-003**: Room availability status updates across the system within 1 second of booking acceptance.
- **SC-004**: 0% overbooking rate (no two "Accepted" bookings for the same room).

## Assumptions

- **Authentication**: Users (Students and Owners) are already authenticated and have appropriate roles.
- **Data Model**: The existing `Room` model can be extended with a status field if it doesn't already have one.
- **Real-time**: Supabase real-time subscriptions will be used to reflect status changes immediately in the UI.
- **Payment**: No reservation fee is required; the booking is a manual agreement between the student and owner.

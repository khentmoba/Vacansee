// Unit tests for VacanSee models
import 'package:flutter_test/flutter_test.dart';
import 'package:vacansee/models/models.dart';

void main() {
  group('UserModel', () {
    test('can create a user model', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, UserRole.student);
    });

    test('copyWith creates a new instance with updated fields', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = user.copyWith(displayName: 'Updated Name');

      expect(updated.uid, 'test-uid'); // unchanged
      expect(updated.displayName, 'Updated Name'); // changed
    });
  });

  group('PropertyModel', () {
    test('can create a property model', () {
      final property = PropertyModel(
        propertyId: 'prop-1',
        ownerId: 'owner-1',
        name: 'Test Property',
        address: '123 Test St',
        lat: 8.5,
        lng: 124.6,
        genderOrientation: GenderOrientation.male,
        amenities: ['wifi', 'ac'],
        priceRange: const PriceRange(min: 3000, max: 5000),
        status: PropertyStatus.verified,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(property.propertyId, 'prop-1');
      expect(property.name, 'Test Property');
      expect(property.isVerified, true);
    });

    test('toJson includes images array', () {
      final property = PropertyModel(
        propertyId: 'prop-1',
        ownerId: 'owner-1',
        name: 'Test Property',
        address: '123 Test St',
        lat: 8.5,
        lng: 124.6,
        genderOrientation: GenderOrientation.male,
        amenities: [],
        priceRange: const PriceRange(min: 3000, max: 5000),
        status: PropertyStatus.verified,
        lastUpdated: DateTime.now(),
        images: ['url1', 'url2'],
      );

      final json = property.toJson();
      expect(json['images'], ['url1', 'url2']);
    });

    test('price range formats correctly', () {
      const priceRange = PriceRange(min: 3000, max: 5000);
      expect(priceRange.formatted, '₱3000 - ₱5000');
    });
  });

  group('RoomModel', () {
    test('can create a room model', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: ['url1', 'url2'],
        capacity: 4,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.roomId, 'room-1');
      expect(room.status, RoomStatus.vacant);
      expect(room.hasVacancy, true);
    });

    test('vacant room has vacancy', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: [],
        capacity: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.hasVacancy, true);
    });

    test('occupied room shows correct availability', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.occupied,
        images: [],
        capacity: 4,
        currentOccupants: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      expect(room.status, RoomStatus.occupied);
      expect(room.availableSlots, 2);
    });

    test('copyWith preserves unmodified fields', () {
      final room = RoomModel(
        roomId: 'room-1',
        propertyId: 'prop-1',
        status: RoomStatus.vacant,
        images: ['url1'],
        capacity: 2,
        lastUpdated: DateTime(2025, 1, 1),
      );

      final updated = room.copyWith(status: RoomStatus.occupied);

      expect(updated.roomId, 'room-1');
      expect(updated.status, RoomStatus.occupied);
      expect(updated.capacity, 2);
    });
  });

  group('BookingModel', () {
    test('toJson includes student biographical fields', () {
      final booking = BookingModel(
        bookingId: 'book-1',
        studentId: 'student-1',
        propertyId: 'prop-1',
        roomId: 'room-1',
        propertyName: 'Test Prop',
        roomDescription: 'Test Room',
        studentName: 'Juan Dela Cruz',
        studentEmail: 'juan@example.com',
        studentPhone: '09123456789',
        status: BookingStatus.pending,
        requestedAt: DateTime(2025, 1, 1),
      );

      final json = booking.toJson();
      expect(json['student_name'], 'Juan Dela Cruz');
      expect(json['student_email'], 'juan@example.com');
      expect(json['student_phone'], '09123456789');
    });
  });
}

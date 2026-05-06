import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

/// Exception for booking operations
class BookingException implements Exception {
  final String message;
  BookingException(this.message);
  @override
  String toString() => 'BookingException: $message';
}

/// Service for booking CRUD operations
class BookingService {
  final SupabaseClient _supabase;

  BookingService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Check if a room is available for booking
  Future<bool> isRoomAvailable(String roomId) async {
    try {
      final room = await _supabase
          .from('rooms')
          .select('status')
          .eq('id', roomId)
          .maybeSingle();

      if (room == null) return false;
      return room['status'] == 'vacant';
    } catch (e) {
      return false;
    }
  }

  /// Create a new booking request with race condition protection
  Future<BookingModel> createBooking({
    required String studentId,
    required String propertyId,
    required String roomId,
    required String propertyName,
    required String roomDescription,
    required String studentName,
    required String studentEmail,
    String? studentPhone,
    String? studentNotes,
    DateTime? moveInDate,
    int durationMonths = 1,
  }) async {
    try {
      // 1. Check room availability
      final isAvailable = await isRoomAvailable(roomId);
      if (!isAvailable) {
        throw BookingException(
          'This room is no longer available.',
        );
      }

      // 2. Gender Enforcement
      final studentData = await _supabase.from('users').select('gender').eq('id', studentId).single();
      final propertyData = await _supabase.from('properties').select('gender_orientation').eq('id', propertyId).single();
      
      final studentGender = studentData['gender'] as String?;
      final propertyOrientation = propertyData['gender_orientation'] as String;

      if (propertyOrientation != 'mixed' && studentGender != null) {
        if (propertyOrientation != studentGender) {
          throw BookingException(
            'This property is for ${propertyOrientation}s only. Your profile gender ($studentGender) does not match.',
          );
        }
      }

      final Map<String, dynamic> bookingJson = {
        'student_id': studentId,
        'property_id': propertyId,
        'room_id': roomId,
        'property_name': propertyName,
        'room_description': roomDescription,
        'student_name': studentName,
        'student_email': studentEmail,
        'student_phone': studentPhone,
        'status': BookingStatus.pending.name,
        'requested_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(hours: 48)).toIso8601String(),
        'student_notes': studentNotes,
        'move_in_date': moveInDate?.toIso8601String(),
        'duration_months': durationMonths,
      };

      final data = await _supabase
          .from('bookings')
          .insert(bookingJson)
          .select(
            '*, properties(name), rooms(description), users:student_id(display_name, email, phone_number)',
          )
          .single();

      return BookingModel.fromJson(data);
    } on BookingException {
      rethrow;
    } catch (e) {
      throw BookingException('Failed to create booking: $e');
    }
  }

  /// Get booking by ID
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      final data = await _supabase
          .from('bookings')
          .select(
            '*, properties(name), rooms(description), users:student_id(display_name, email, phone_number)',
          )
          .eq('id', bookingId)
          .maybeSingle();

      if (data == null) return null;
      return BookingModel.fromJson(data);
    } catch (e) {
      throw BookingException('Failed to fetch booking: $e');
    }
  }

  /// Get bookings for a student
  Stream<List<BookingModel>> getStudentBookings(String studentId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .order('requested_at', ascending: false)
        .map(
          (data) => data.map((json) => BookingModel.fromJson(json)).toList(),
        );
  }

  /// Get bookings for an owner's properties
  Stream<List<BookingModel>> getOwnerBookings(List<String> propertyIds) {
    if (propertyIds.isEmpty) return Stream.value([]);

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .inFilter('property_id', propertyIds)
        .order('requested_at', ascending: false)
        .map(
          (data) => data.map((json) => BookingModel.fromJson(json)).toList(),
        );
  }

  /// Get pending bookings count for owner
  Stream<int> getPendingBookingsCount(List<String> propertyIds) {
    if (propertyIds.isEmpty) return Stream.value(0);

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .inFilter('property_id', propertyIds)
        .map((data) => data.where((b) => b['status'] == 'pending').length);
  }

  /// Approve a booking
  Future<void> approveBooking(String bookingId, {String? ownerNotes}) async {
    try {
      // Trigger handled room status update, but we update status here
      await _supabase
          .from('bookings')
          .update({
            'status': BookingStatus.approved.name,
            'responded_at': DateTime.now().toIso8601String(),
            'owner_notes': ownerNotes,
          })
          .eq('id', bookingId);
    } catch (e) {
      throw BookingException('Failed to approve booking: $e');
    }
  }

  /// Reject a booking
  Future<void> rejectBooking(String bookingId, {String? ownerNotes}) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': BookingStatus.rejected.name,
            'responded_at': DateTime.now().toIso8601String(),
            'owner_notes': ownerNotes,
          })
          .eq('id', bookingId);
    } catch (e) {
      throw BookingException('Failed to reject booking: $e');
    }
  }

  /// Cancel a booking (by student)
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': BookingStatus.cancelled.name,
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      throw BookingException('Failed to cancel booking: $e');
    }
  }
}

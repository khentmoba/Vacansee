import 'package:flutter/material.dart';

/// Booking status enum
enum BookingStatus { pending, approved, rejected, cancelled, completed }

/// Booking model representing a room booking request
class BookingModel {
  final String bookingId;
  final String studentId;
  final String propertyId;
  final String roomId;
  final String propertyName;
  final String roomDescription;
  final String studentName;
  final String studentEmail;
  final String? studentPhone;
  final BookingStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? ownerNotes;
  final String? studentNotes;
  final DateTime? moveInDate;
  final int durationMonths;

  const BookingModel({
    required this.bookingId,
    required this.studentId,
    required this.propertyId,
    required this.roomId,
    required this.propertyName,
    required this.roomDescription,
    required this.studentName,
    required this.studentEmail,
    this.studentPhone,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.ownerNotes,
    this.studentNotes,
    this.moveInDate,
    this.durationMonths = 1,
  });

  factory BookingModel.fromJson(Map<String, dynamic> data) {
    // Helper to safely extract joined table data
    String extractJoined(
      String table,
      String field, {
      String defaultValue = '',
    }) {
      if (data[table] != null && data[table] is Map) {
        return data[table][field] as String? ?? defaultValue;
      }
      return defaultValue;
    }

    return BookingModel(
      bookingId: data['id'] as String? ?? data['booking_id'] as String? ?? '',
      studentId: data['student_id'] as String? ?? '',
      propertyId: data['property_id'] as String? ?? '',
      roomId: data['room_id'] as String? ?? '',
      // If flattened fallback was provided, use it; otherwise extract from join
      propertyName:
          data['property_name'] as String? ??
          extractJoined('properties', 'name'),
      roomDescription:
          data['room_description'] as String? ??
          extractJoined('rooms', 'description'),
      studentName:
          data['student_name'] as String? ??
          extractJoined('users', 'display_name'),
      studentEmail:
          data['student_email'] as String? ?? extractJoined('users', 'email'),
      studentPhone:
          data['student_phone'] as String? ??
          extractJoined('users', 'phone_number', defaultValue: ''),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      requestedAt: data['requested_at'] != null
          ? DateTime.parse(data['requested_at'] as String)
          : DateTime.now(),
      respondedAt: data['responded_at'] != null
          ? DateTime.parse(data['responded_at'] as String)
          : null,
      ownerNotes: data['owner_notes'] as String?,
      studentNotes: data['student_notes'] as String?,
      moveInDate: data['move_in_date'] != null
          ? DateTime.parse(data['move_in_date'] as String)
          : null,
      durationMonths: (data['duration_months'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bookingId.isNotEmpty) 'id': bookingId,
      'student_id': studentId,
      'property_id': propertyId,
      'room_id': roomId,
      'property_name': propertyName,
      'room_description': roomDescription,
      'status': status.name,
      'student_name': studentName,
      'student_email': studentEmail,
      'student_phone': studentPhone,
      'requested_at': requestedAt.toIso8601String(),
      if (respondedAt != null) 'responded_at': respondedAt!.toIso8601String(),
      'owner_notes': ownerNotes,
      'student_notes': studentNotes,
      if (moveInDate != null) 'move_in_date': moveInDate!.toIso8601String(),
      'duration_months': durationMonths,
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? studentId,
    String? propertyId,
    String? roomId,
    String? propertyName,
    String? roomDescription,
    String? studentName,
    String? studentEmail,
    String? studentPhone,
    BookingStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? ownerNotes,
    String? studentNotes,
    DateTime? moveInDate,
    int? durationMonths,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      studentId: studentId ?? this.studentId,
      propertyId: propertyId ?? this.propertyId,
      roomId: roomId ?? this.roomId,
      propertyName: propertyName ?? this.propertyName,
      roomDescription: roomDescription ?? this.roomDescription,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentPhone: studentPhone ?? this.studentPhone,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      studentNotes: studentNotes ?? this.studentNotes,
      moveInDate: moveInDate ?? this.moveInDate,
      durationMonths: durationMonths ?? this.durationMonths,
    );
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFA000);
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return const Color(0xFF5287B2);
    }
  }

  @override
  String toString() => 'BookingModel(id: $bookingId, status: $status)';
}

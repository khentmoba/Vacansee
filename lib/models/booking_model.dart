// ignore_for_file: invalid_annotation_target
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

/// Booking status enum
enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

/// Booking model representing a room booking request
@freezed
class BookingModel with _$BookingModel {
  const BookingModel._(); // Supporting custom methods

  const factory BookingModel({
    @JsonKey(name: 'id') required String bookingId,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'property_id') required String propertyId,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'property_name') required String propertyName,
    @JsonKey(name: 'room_description') required String roomDescription,
    @JsonKey(name: 'student_name') required String studentName,
    @JsonKey(name: 'student_email') required String studentEmail,
    @JsonKey(name: 'student_phone') String? studentPhone,
    required BookingStatus status,
    @JsonKey(name: 'requested_at') required DateTime requestedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'owner_notes') String? ownerNotes,
    @JsonKey(name: 'student_notes') String? studentNotes,
    @JsonKey(name: 'move_in_date') DateTime? moveInDate,
    @JsonKey(name: 'duration_months') @Default(1) int durationMonths,
    @JsonKey(name: 'owner_name') String? ownerName,
    @JsonKey(name: 'monthly_rate') @Default(0) int monthlyRate,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(_flattenJson(json));

  static Map<String, dynamic> _flattenJson(Map<String, dynamic> json) {
    final Map<String, dynamic> flattened = Map<String, dynamic>.from(json);

    // Extract from properties join
    if (json['properties'] != null && json['properties'] is Map) {
      flattened['property_name'] ??= json['properties']['name'];
      
      // Handle nested owner join if present
      if (json['properties']['owner'] != null && json['properties']['owner'] is Map) {
        flattened['owner_name'] ??= json['properties']['owner']['display_name'];
      }
    }

    // Extract from rooms join
    if (json['rooms'] != null && json['rooms'] is Map) {
      flattened['room_description'] ??= json['rooms']['description'];
      flattened['monthly_rate'] ??= json['rooms']['monthly_rate'];
    }

    // Extract from users join (student profile)
    if (json['users'] != null && json['users'] is Map) {
      flattened['student_name'] ??= json['users']['display_name'];
      flattened['student_email'] ??= json['users']['email'];
      flattened['student_phone'] ??= json['users']['phone_number'];
    }

    // Map 'id' to 'bookingId'
    flattened['id'] ??= json['id'] ?? json['booking_id'];

    return flattened;
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.expired:
        return 'Expired';
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
      case BookingStatus.expired:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return const Color(0xFF5287B2);
    }
  }
}

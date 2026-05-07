// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      bookingId: json['id'] as String,
      studentId: json['student_id'] as String,
      propertyId: json['property_id'] as String,
      roomId: json['room_id'] as String,
      propertyName: json['property_name'] as String,
      roomDescription: json['room_description'] as String,
      studentName: json['student_name'] as String,
      studentEmail: json['student_email'] as String,
      studentPhone: json['student_phone'] as String?,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      requestedAt: DateTime.parse(json['requested_at'] as String),
      respondedAt: json['responded_at'] == null
          ? null
          : DateTime.parse(json['responded_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      ownerNotes: json['owner_notes'] as String?,
      studentNotes: json['student_notes'] as String?,
      moveInDate: json['move_in_date'] == null
          ? null
          : DateTime.parse(json['move_in_date'] as String),
      durationMonths: (json['duration_months'] as num?)?.toInt() ?? 1,
      ownerName: json['owner_name'] as String?,
      monthlyRate: (json['monthly_rate'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.bookingId,
      'student_id': instance.studentId,
      'property_id': instance.propertyId,
      'room_id': instance.roomId,
      'property_name': instance.propertyName,
      'room_description': instance.roomDescription,
      'student_name': instance.studentName,
      'student_email': instance.studentEmail,
      'student_phone': instance.studentPhone,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'requested_at': instance.requestedAt.toIso8601String(),
      'responded_at': instance.respondedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'owner_notes': instance.ownerNotes,
      'student_notes': instance.studentNotes,
      'move_in_date': instance.moveInDate?.toIso8601String(),
      'duration_months': instance.durationMonths,
      'owner_name': instance.ownerName,
      'monthly_rate': instance.monthlyRate,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.approved: 'approved',
  BookingStatus.rejected: 'rejected',
  BookingStatus.expired: 'expired',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};

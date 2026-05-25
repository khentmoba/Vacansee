// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  notificationId: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  isRead: json['is_read'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.notificationId,
  'user_id': instance.userId,
  'title': instance.title,
  'message': instance.message,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$NotificationTypeEnumMap = {
  NotificationType.bookingRequest: 'booking_request',
  NotificationType.bookingAccepted: 'booking_accepted',
  NotificationType.bookingDeclined: 'booking_declined',
  NotificationType.bookingExpired: 'booking_expired',
  NotificationType.system: 'system',
};

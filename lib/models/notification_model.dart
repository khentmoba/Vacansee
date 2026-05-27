// ignore_for_file: invalid_annotation_target
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Type of notification
enum NotificationType {
  @JsonValue('booking_request')
  bookingRequest,
  @JsonValue('booking_accepted')
  bookingAccepted,
  @JsonValue('booking_declined')
  bookingDeclined,
  @JsonValue('booking_expired')
  bookingExpired,
  @JsonValue('property_submitted')
  propertySubmitted,
  @JsonValue('property_verified')
  propertyVerified,
  @JsonValue('property_rejected')
  propertyRejected,
  @JsonValue('owner_verification_request')
  ownerVerificationRequest,
  @JsonValue('system')
  system,
}

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    @JsonKey(name: 'id') required String notificationId,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String message,
    required NotificationType type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    Map<String, dynamic>? metadata,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  IconData get icon {
    switch (type) {
      case NotificationType.bookingRequest:
        return Icons.bookmark_add;
      case NotificationType.bookingAccepted:
        return Icons.check_circle;
      case NotificationType.bookingDeclined:
        return Icons.cancel;
      case NotificationType.bookingExpired:
        return Icons.timer_off;
      case NotificationType.propertySubmitted:
        return Icons.add_home_work_rounded;
      case NotificationType.propertyVerified:
        return Icons.verified_rounded;
      case NotificationType.propertyRejected:
        return Icons.do_not_disturb_alt_rounded;
      case NotificationType.ownerVerificationRequest:
        return Icons.verified_user_rounded;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.bookingRequest:
        return Colors.blue;
      case NotificationType.bookingAccepted:
        return Colors.green;
      case NotificationType.bookingDeclined:
        return Colors.red;
      case NotificationType.bookingExpired:
        return Colors.grey;
      case NotificationType.propertySubmitted:
        return Colors.orange;
      case NotificationType.propertyVerified:
        return Colors.green;
      case NotificationType.propertyRejected:
        return Colors.red;
      case NotificationType.ownerVerificationRequest:
        return Colors.purple;
      case NotificationType.system:
        return Colors.orange;
    }
  }
}

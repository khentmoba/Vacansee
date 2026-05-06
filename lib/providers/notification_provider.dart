import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _unreadSubscription;

  NotificationProvider({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Initialize listeners for a specific user
  void initialize(String userId) {
    _cancelSubscriptions();

    _isLoading = true;
    notifyListeners();

    _notificationSubscription = _notificationService
        .getNotifications(userId)
        .listen((data) {
          _notifications = data;
          _isLoading = false;
          notifyListeners();
        });

    _unreadSubscription = _notificationService
        .getUnreadCount(userId)
        .listen((count) {
          _unreadCount = count;
          notifyListeners();
        });
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    await _notificationService.markAllAsRead(userId);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }

  void _cancelSubscriptions() {
    _notificationSubscription?.cancel();
    _unreadSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

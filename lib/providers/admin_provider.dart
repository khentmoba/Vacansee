import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/admin_stats_model.dart';
import '../services/admin_service.dart';

import '../models/user_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;

  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService();

  AdminStatsModel? _stats;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AdminStatsModel>? _statsSubscription;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  // Search & Filters
  String _searchQuery = '';
  UserRole? _roleFilter;

  AdminStatsModel? get stats => _stats;
  List<UserModel> get users {
    var filtered = _users;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((u) => 
        u.displayName.toLowerCase().contains(q) || 
        u.email.toLowerCase().contains(q)
      ).toList();
    }
    if (_roleFilter != null) {
      filtered = filtered.where((u) => u.role == _roleFilter).toList();
    }
    return filtered;
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // User stats from the full list
  int get totalUsersCount => _users.length;
  int get tenantsCount => _users.where((u) => u.role == UserRole.student).length;
  int get ownersCount => _users.where((u) => u.role == UserRole.owner).length;
  int get adminsCount => _users.where((u) => u.role == UserRole.admin).length;

  /// Load ecosystem statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _adminService.getEcosystemStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all users
  Future<void> loadAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _adminService.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to real-time admin statistics
  void subscribeToStats() {
    _statsSubscription?.cancel();
    _statsSubscription = _adminService.getEcosystemStatsStream().listen(
      (stats) {
        _stats = stats;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to sync stats: $error';
        notifyListeners();
      },
    );
  }

  /// Subscribe to real-time user list
  void subscribeToAllUsers() {
    _usersSubscription?.cancel();
    _usersSubscription = _adminService.getAllUsersStream().listen(
      (users) {
        _users = users;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to sync users: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  /// Update filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(UserRole? role) {
    _roleFilter = role;
    notifyListeners();
  }

  /// Update a user's profile
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _adminService.updateUser(uid, fields);
      // Stream will handle the update automatically
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String uid) async {
    try {
      await _adminService.deleteUser(uid);
      // Stream will handle the update automatically
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

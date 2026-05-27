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
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          displayName: fields['display_name'] as String?,
          email: fields['email'] as String?,
          phoneNumber: fields['phone_number'] as String?,
          role: fields['role'] != null
              ? UserRole.values.firstWhere((r) => r.name == fields['role'])
              : null,
          gender: fields['gender'] as String?,
          firstName: fields['first_name'] as String?,
          lastName: fields['last_name'] as String?,
          address: fields['address'] as String?,
          businessName: fields['business_name'] as String?,
          businessPermitNo: fields['business_permit_no'] as String?,
          emergencyContactName: fields['emergency_contact_name'] as String?,
          emergencyContactPhone: fields['emergency_contact_phone'] as String?,
        );
      }
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
      _users.removeWhere((u) => u.uid == uid);
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

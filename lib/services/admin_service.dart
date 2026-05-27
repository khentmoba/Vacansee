import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_stats_model.dart';
import '../models/user_model.dart';

class AdminService {
  final SupabaseClient _supabase;

  AdminService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch platform-wide statistics
  Future<AdminStatsModel> getEcosystemStats() async {
    try {
      // 1. Properties
      final totalPropsData = await _supabase.from('properties').select('id').neq('status', 'deleted');
      final totalProperties = totalPropsData.length;

      final verifiedPropsData = await _supabase.from('properties').select('id').eq('status', 'verified');
      final verifiedProperties = verifiedPropsData.length;

      // 2. Users
      final allUsersData = await _supabase.from('users').select('id, role');
      final totalUsers = allUsersData.length;
      final totalOwners = allUsersData.where((u) => u['role'] == 'owner').length;
      final totalStudents = allUsersData.where((u) => u['role'] == 'student').length;

      // 3. Bookings
      final bookingsData = await _supabase.from('bookings').select('id, status, student_id');
      final totalBookings = bookingsData.length;
      final pendingBookings = bookingsData.where((b) => b['status'] == 'pending').length;
      
      // Active tenants = unique students with approved/completed bookings
      final activeTenants = bookingsData
          .where((b) => b['status'] == 'approved' || b['status'] == 'completed')
          .map((b) => b['student_id'])
          .toSet()
          .length;

      // 4. Occupancy Rate (Rooms occupied / Total rooms)
      final roomsData = await _supabase.from('rooms').select('status');
      final totalRooms = roomsData.length;
      final occupiedRooms = roomsData.where((r) => r['status'] == 'occupied').length;
      final occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms) : 0.0;

      return AdminStatsModel(
        totalProperties: totalProperties,
        verifiedProperties: verifiedProperties,
        totalOwners: totalOwners,
        totalStudents: totalStudents,
        totalUsers: totalUsers,
        totalBookings: totalBookings,
        pendingBookings: pendingBookings,
        activeTenants: activeTenants,
        occupancyRate: occupancyRate,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch ecosystem stats: $e');
    }
  }
  /// Fetch all users registered on the platform
  Future<List<UserModel>> getAllUsers() async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .order('display_name', ascending: true);

      return (data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Update a user's fields
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _supabase.from('users').update(fields).eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete a user
  Future<void> deleteUser(String uid) async {
    try {
      await _supabase.from('users').delete().eq('id', uid);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Toggle user verification status
  Future<void> toggleUserVerification(String uid, bool isVerified) async {
    try {
      await _supabase
          .from('users')
          .update({'is_verified': isVerified})
          .eq('id', uid);
    } catch (e) {
      throw Exception('Failed to toggle verification: $e');
    }
  }
}

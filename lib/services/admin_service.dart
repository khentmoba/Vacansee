import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_stats_model.dart';

class AdminService {
  final SupabaseClient _supabase;

  AdminService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch platform-wide statistics
  Future<AdminStatsModel> getEcosystemStats() async {
    try {
      // 1. Count all non-deleted properties
      final totalPropsData = await _supabase
          .from('properties')
          .select('id')
          .neq('status', 'deleted');
      final totalProperties = totalPropsData.length;

      // 2. Count verified properties
      final verifiedPropsData = await _supabase
          .from('properties')
          .select('id')
          .eq('status', 'verified');
      final verifiedProperties = verifiedPropsData.length;

      // 3. Count owners
      final ownersData = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'owner');
      final totalOwners = ownersData.length;

      // 4. Count students
      final studentsData = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'student');
      final totalStudents = studentsData.length;

      return AdminStatsModel(
        totalProperties: totalProperties,
        verifiedProperties: verifiedProperties,
        totalOwners: totalOwners,
        totalStudents: totalStudents,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch ecosystem stats: $e');
    }
  }
}

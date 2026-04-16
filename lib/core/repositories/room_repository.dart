import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/room_model.dart';

/// Exception for room repository operations
class RoomException implements Exception {
  final String message;
  RoomException(this.message);
  @override
  String toString() => 'RoomException: $message';
}

/// Repository for handling Room-related data and real-time streams
class RoomRepository {
  final SupabaseClient _supabase;

  RoomRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Stream of rooms with vacancy status, joined with property data
  /// Uses the public.room_vacancies view for real-time relational streaming
  Stream<List<RoomModel>> getVacancyStream() {
    return _supabase
        .from('room_vacancies')
        .stream(primaryKey: ['id'])
        .order('last_updated', ascending: false)
        .map((data) {
          return data.map((json) => RoomModel.fromJson(json)).toList();
        });
  }

  /// Check if a room is available for booking (Pre-check for race conditions)
  /// Explicitly avoids 'dynamic' by expected return type
  Future<bool> checkRoomAvailability(String roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('status')
          .eq('id', roomId)
          .maybeSingle();
      
      if (response == null) return false;
      
      final String status = response['status'] as String;
      return status == 'vacant';
    } catch (e) {
      throw RoomException('Failed to check availability: $e');
    }
  }

  /// Toggle room vacancy status
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    try {
      await _supabase.from('rooms').update({
        'status': status.name,
        'last_updated': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
    } catch (e) {
      throw RoomException('Failed to update room status: $e');
    }
  }
}

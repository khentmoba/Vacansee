import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

/// Service for managing property listings and associated assets.
/// 
/// Follows the Listing Management contract for complex mutations.
class ListingService {
  final SupabaseClient _supabase;

  ListingService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Updates an existing property and its associated rooms.
  /// 
  /// Triggers re-verification if the address changes.
  Future<void> updatePropertyListing({
    required PropertyModel property,
    required List<RoomModel> rooms,
    required List<String> deletedRoomIds,
    required List<String> deletedImagePaths,
  }) async {
    try {
      // 1. Fetch current status and address for comparison
      final currentData = await _supabase
          .from('properties')
          .select('address, status')
          .eq('id', property.propertyId)
          .single();

      final currentAddress = currentData['address'] as String;
      
      // 2. Determine if re-verification is needed
      var status = property.status;
      if (property.address != currentAddress) {
        status = PropertyStatus.pending;
      }

      final updatedProperty = property.copyWith(
        status: status,
        lastUpdated: DateTime.now(),
      );

      // 3. Update Property
      final propertyJson = updatedProperty.toJson();
      propertyJson.remove('id');
      propertyJson.remove('has_vacancy');
      
      await _supabase
          .from('properties')
          .update(propertyJson)
          .eq('id', property.propertyId);

      // 4. Delete removed rooms
      if (deletedRoomIds.isNotEmpty) {
        await _supabase.from('rooms').delete().inFilter('id', deletedRoomIds);
      }

      // 5. Upsert Rooms
      for (final room in rooms) {
        final roomJson = room.toJson();
        if (room.roomId.isEmpty || room.roomId.startsWith('temp_')) {
          roomJson.remove('id');
        }
        roomJson.remove('is_available');
        roomJson.remove('property_name');
        
        await _supabase.from('rooms').upsert(roomJson);
      }

      // 6. Delete images from Storage
      if (deletedImagePaths.isNotEmpty) {
        await _supabase.storage.from('property_images').remove(deletedImagePaths);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Permanently removes a property and all associated assets.
  Future<void> deletePropertyListing(String propertyId) async {
    try {
      // 1. Fetch property to get images list
      final data = await _supabase
          .from('properties')
          .select('images')
          .eq('id', propertyId)
          .single();
      
      final List<String> images = List<String>.from(data['images'] ?? []);

      // 2. Fetch all rooms to get their images
      final roomsData = await _supabase
          .from('rooms')
          .select('images')
          .eq('property_id', propertyId);
      
      final List<String> roomImages = (roomsData as List)
          .expand((r) => List<String>.from(r['images'] ?? []))
          .toList();

      // 3. Delete from Database (Cascade handles rooms and bookings)
      // We do this BEFORE storage cleanup to ensure the listing is removed from UI 
      // even if storage cleanup has issues.
      await _supabase.from('properties').delete().eq('id', propertyId);

      // 4. Cleanup Storage
      final allImages = [...images, ...roomImages].where((img) => img.isNotEmpty).toSet().toList();
      
      if (allImages.isNotEmpty) {
        try {
          // Extract paths from Supabase storage URLs
          final paths = allImages.map((url) {
            try {
              final uri = Uri.parse(url);
              final segments = uri.pathSegments;
              final bucketIndex = segments.indexOf('property_images');
              
              if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
                return segments.sublist(bucketIndex + 1).join('/');
              }
            } catch (e) {
              debugPrint('Error parsing image URL for deletion: $url - $e');
            }
            return null;
          }).whereType<String>().toList();

          if (paths.isNotEmpty) {
            await _supabase.storage.from('property_images').remove(paths);
          }
        } catch (e) {
          // Log storage cleanup error but don't fail the whole operation
          // since the DB records are already gone.
          debugPrint('Non-blocking storage cleanup error: $e');
        }
      }
    } catch (e) {
      debugPrint('Delete property listing failed: $e');
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

import 'storage_service.dart';

/// Exception for property operations
class PropertyException implements Exception {
  final String message;
  PropertyException(this.message);
  @override
  String toString() => 'PropertyException: $message';
}

/// Service for property CRUD operations
class PropertyService {
  final SupabaseClient _supabase;
  final StorageService _storage;

  PropertyService({SupabaseClient? supabase, StorageService? storage})
    : _supabase = supabase ?? Supabase.instance.client,
      _storage = storage ?? StorageService(supabase: supabase);

  /// Create a new property
  Future<PropertyModel> createProperty({
    required String ownerId,
    required String name,
    required String address,
    required double lat,
    required double lng,
    required GenderOrientation genderOrientation,
    required List<String> amenities,
    required PriceRange priceRange,
    String? description,
    List<String>? images,
  }) async {
    try {
      final property = PropertyModel(
        propertyId: '', // DB generates UUID
        ownerId: ownerId,
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        genderOrientation: genderOrientation,
        amenities: amenities,
        priceRange: priceRange,
        status: PropertyStatus.pending,
        lastUpdated: DateTime.now(),
        description: description,
        images: images ?? [],
      );

      final json = property.toJson();
      json.remove('id'); // Explicitly remove for insert
      json.remove('has_vacancy'); // UI-only field not in DB schema

      final response = await _supabase
          .from('properties')
          .insert(json)
          .select()
          .single();

      return PropertyModel.fromJson(response);
    } catch (e) {
      throw PropertyException('Failed to create property: $e');
    }
  }

  /// Get a single property by ID
  Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      final data = await _supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .maybeSingle();

      if (data == null) return null;
      return PropertyModel.fromJson(data);
    } catch (e) {
      throw PropertyException('Failed to fetch property: $e');
    }
  }

  /// Get all properties with optional filters
  Stream<List<PropertyModel>> getProperties({
    String? ownerId,
    GenderOrientation? genderOrientation,
    int? minPrice,
    int? maxPrice,
    List<String>? amenities,
    String? searchQuery,
  }) {
    return _supabase.from('properties').stream(primaryKey: ['id']).map((
      snapshot,
    ) {
      var properties = snapshot
          .map((doc) => PropertyModel.fromJson(doc))
          .toList();

      if (ownerId != null) {
        properties = properties.where((p) => p.ownerId == ownerId).toList();
      }
      if (genderOrientation != null) {
        properties = properties
            .where((p) => p.genderOrientation == genderOrientation)
            .toList();
      }
      if (minPrice != null) {
        properties = properties
            .where((p) => p.priceRange.min >= minPrice)
            .toList();
      }
      if (maxPrice != null) {
        properties = properties
            .where((p) => p.priceRange.max <= maxPrice)
            .toList();
      }
      if (amenities != null && amenities.isNotEmpty) {
        properties = properties
            .where((p) => amenities.every((a) => p.amenities.contains(a)))
            .toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        properties = properties.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) ||
              p.address.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return properties;
    });
  }

  /// Update a property
  Future<void> updateProperty(PropertyModel property) async {
    try {
      // 1. Fetch current address to check for changes
      final currentData = await _supabase
          .from('properties')
          .select('address')
          .eq('id', property.propertyId)
          .single();

      final currentAddress = currentData['address'] as String;

      // 2. Determine if status should be reset to pending
      // Resubmit if address changed OR if it was previously rejected
      var status = property.status;
      String? rejectionReason = property.rejectionReason;

      if (property.address != currentAddress ||
          property.status == PropertyStatus.rejected) {
        status = PropertyStatus.pending;
        rejectionReason = null; // Clear reason on resubmission
      }

      final updated = property.copyWith(
        status: status,
        rejectionReason: rejectionReason,
        lastUpdated: DateTime.now(),
      );

      final json = updated.toJson();
      json.remove('has_vacancy'); // UI-only field not in DB schema

      await _supabase
          .from('properties')
          .update(json)
          .eq('id', property.propertyId);
    } catch (e) {
      throw PropertyException('Failed to update property: $e');
    }
  }

  /// Soft delete a property and clean up associated storage
  Future<void> deleteProperty(String propertyId) async {
    try {
      // 1. Fetch property to get images and associated data
      final data = await _supabase
          .from('properties')
          .select('images')
          .eq('id', propertyId)
          .single();

      final List<String> images =
          (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      // 2. Perform soft delete
      await _supabase
          .from('properties')
          .update({'status': 'deleted'})
          .eq('id', propertyId);

      // 3. Clean up storage in the background
      if (images.isNotEmpty) {
        _storage.deletePropertyImages(images).catchError((e) {
          // Log but don't fail the deletion if storage cleanup fails
          debugPrint('Storage cleanup failed during property deletion: $e');
        });
      }
    } catch (e) {
      throw PropertyException('Failed to delete property: $e');
    }
  }

  /// Moderate a property (Verify/Reject)
  Future<void> moderateProperty({
    required String propertyId,
    required PropertyStatus status,
    String? reason,
  }) async {
    try {
      await _supabase
          .from('properties')
          .update({
            'status': status.name,
            'rejection_reason': reason,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .select()
          .single();
    } catch (e) {
      throw PropertyException('Failed to moderate property: $e');
    }
  }

  /// Add a room to a property
  Future<RoomModel> addRoom({
    required String propertyId,
    required int capacity,
    required int monthlyRate,
    RoomStatus status = RoomStatus.vacant,
    List<String>? images,
    String? description,
  }) async {
    try {
      final room = RoomModel(
        roomId: '', // Generated by DB
        propertyId: propertyId,
        status: status,
        images: images ?? [],
        capacity: capacity,
        monthlyRate: monthlyRate,
        description: description,
        lastUpdated: DateTime.now(),
      );

      final json = room.toJson();
      json.remove('id');
      json.remove('is_available'); // Virtual field from view
      json.remove('property_name'); // Virtual field from view

      final result = await _supabase
          .from('rooms')
          .insert(json)
          .select()
          .single();

      return RoomModel.fromJson(result);
    } catch (e) {
      throw PropertyException('Failed to add room: $e');
    }
  }

  /// Get rooms for a property
  Stream<List<RoomModel>> getRooms(String propertyId) {
    return _supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .eq('property_id', propertyId)
        .order('last_updated')
        .map((data) => data.map((json) => RoomModel.fromJson(json)).toList());
  }

  /// Get all rooms across all properties (for real-time vacancy tracking)
  Stream<List<RoomModel>> getAllRooms() {
    return _supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .order('last_updated')
        .map((data) => data.map((json) => RoomModel.fromJson(json)).toList());
  }

  /// Update room status
  Future<void> updateRoomStatus(
    String propertyId,
    String roomId,
    RoomStatus status,
  ) async {
    try {
      await _supabase
          .from('rooms')
          .update({
            'status': status.name,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId);
    } catch (e) {
      throw PropertyException('Failed to update room: $e');
    }
  }

  /// Delete a room
  Future<void> deleteRoom(String propertyId, String roomId) async {
    try {
      await _supabase.from('rooms').delete().eq('id', roomId);
    } catch (e) {
      throw PropertyException('Failed to delete room: $e');
    }
  }

  /// Get properties by owner
  Stream<List<PropertyModel>> getOwnerProperties(String ownerId) {
    return _supabase
        .from('properties')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .order('last_updated', ascending: false)
        .map((data) => data.map((doc) => PropertyModel.fromJson(doc)).toList());
  }
}

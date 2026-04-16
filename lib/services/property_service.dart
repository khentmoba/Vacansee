import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

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

  PropertyService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

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
        status: PropertyStatus.verified,
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
      final updated = property.copyWith(lastUpdated: DateTime.now());
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

  /// Delete a property and its rooms
  Future<void> deleteProperty(String propertyId) async {
    try {
      // Postgres ON DELETE CASCADE will handle rooms if set up correctly,
      // but otherwise we manually delete rooms first
      await _supabase.from('rooms').delete().eq('property_id', propertyId);
      await _supabase.from('properties').delete().eq('id', propertyId);
    } catch (e) {
      throw PropertyException('Failed to delete property: $e');
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

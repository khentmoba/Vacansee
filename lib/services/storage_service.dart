import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception for storage operations
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

/// Service for Supabase Storage operations
class StorageService {
  final SupabaseClient _supabase;
  final String bucketName = 'property_images';

  StorageService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Upload property image to Supabase Storage
  /// Returns the public download URL
  Future<String> uploadPropertyImage({
    required String propertyId,
    required Uint8List file,
    String? filename,
  }) async {
    try {
      final name = filename ?? DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'properties/$propertyId/images/$name.jpg';

      await _supabase.storage
          .from(bucketName)
          .upload(
            path,
            file as dynamic, // Support both File and Uint8List
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String downloadUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(path);
      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  /// Upload multiple property images
  /// Returns list of download URLs
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<Uint8List> files,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final url = await uploadPropertyImage(
        propertyId: propertyId,
        file: files[i],
        filename: 'image_$i',
      );
      urls.add(url);
    }

    return urls;
  }

  /// Delete property image from storage parsing its public URL
  Future<void> deletePropertyImage(String imageUrl) async {
    try {
      // imageUrl looks like: https://[projectId].supabase.co/storage/v1/object/public/[bucketName]/[path]
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      // We expect the path to be after .../public/[bucketName]/[path]
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final path = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(bucketName).remove([path]);
      } else {
        throw Exception("Could not parse storage path from URL");
      }
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

  /// Upload room image
  Future<String> uploadRoomImage({
    required String propertyId,
    required String roomId,
    required Uint8List file,
  }) async {
    try {
      final name = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'properties/$propertyId/rooms/$roomId/$name.jpg';

      await _supabase.storage
          .from(bucketName)
          .upload(
            path,
            file as dynamic, // Support both File and Uint8List
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw StorageException('Failed to upload room image: $e');
    }
  }
}

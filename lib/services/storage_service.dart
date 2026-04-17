import 'package:flutter/foundation.dart';
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
          .uploadBinary(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
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

  /// Delete multiple property images
  Future<void> deletePropertyImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    final pathsToDelete = <String>[];

    for (final imageUrl in imageUrls) {
      try {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final bucketIndex = pathSegments.indexOf(bucketName);
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final path = pathSegments.sublist(bucketIndex + 1).join('/');
          pathsToDelete.add(path);
        }
      } catch (e) {
        // Log and continue
        debugPrint('Skipping invalid image URL: $imageUrl');
      }
    }

    if (pathsToDelete.isNotEmpty) {
      try {
        await _supabase.storage.from(bucketName).remove(pathsToDelete);
      } catch (e) {
        throw StorageException('Failed to delete images: $e');
      }
    }
  }

  /// Delete property image from storage parsing its public URL
  Future<void> deletePropertyImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final path = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

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
          .uploadBinary(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw StorageException('Failed to upload room image: $e');
    }
  }
}

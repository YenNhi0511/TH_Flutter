import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Service to handle image uploads to Cloudinary
/// Free tier: 10GB storage, 25 monthly credits
class CloudinaryService {
  static const String _cloudName = 'dx3xaceda';
  static const String _uploadPreset =
      'mangxahoi_preset'; // Sẽ tạo trong Dashboard

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Upload image to Cloudinary and return the URL
  ///
  /// [imagePath] - Local file path of the image
  /// [folder] - Folder name in Cloudinary (e.g., 'posts', 'profiles')
  /// [userId] - User ID to organize images
  ///
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage({
    required String imagePath,
    required String folder,
    required String userId,
  }) async {
    try {
      final file = File(imagePath);

      // Upload to Cloudinary with folder structure
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: '$folder/$userId', // e.g., posts/user123
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Return secure HTTPS URL
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Delete image from Cloudinary
  ///
  /// [publicId] - Public ID of the image (extracted from URL)
  ///
  /// Note: Deletion requires authenticated API calls
  /// For simplicity, we'll keep old images (10GB is enough for learning)
  Future<void> deleteImage(String publicId) async {
    // Cloudinary free tier doesn't support deletion via mobile SDK
    // Images will be auto-deleted after storage limit if needed
    // Or you can delete manually from Dashboard
    throw UnimplementedError(
      'Image deletion requires backend API. '
      'Please delete manually from Cloudinary Dashboard if needed.',
    );
  }

  /// Get optimized image URL with transformations
  ///
  /// [url] - Original Cloudinary URL
  /// [width] - Desired width
  /// [height] - Desired height
  /// [quality] - Image quality (auto, 1-100)
  ///
  /// Returns optimized URL
  static String getOptimizedUrl(
    String url, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    // Example: https://res.cloudinary.com/demo/image/upload/v1234/sample.jpg
    // Becomes: https://res.cloudinary.com/demo/image/upload/w_300,h_300,q_auto/v1234/sample.jpg

    if (!url.contains('cloudinary.com')) return url;

    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_auto'); // Auto format (WebP if supported)

    final transformation = transformations.join(',');

    // Insert transformation after /upload/
    return url.replaceFirst('/upload/', '/upload/$transformation/');
  }
}

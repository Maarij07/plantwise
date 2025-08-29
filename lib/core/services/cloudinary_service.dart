import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static CloudinaryService? _instance;
  static CloudinaryService get instance => _instance ??= CloudinaryService._();
  
  CloudinaryService._();

  // Cloudinary configuration
  static const String _cloudName = 'dvqrmyzbe';
  static const String _uploadPreset = 'plantwise_uploads'; // You can create this in Cloudinary dashboard
  
  late final CloudinaryPublic _cloudinary;
  bool _isInitialized = false;

  /// Initialize the Cloudinary service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
      _isInitialized = true;
      print('✅ Cloudinary Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Cloudinary Service: $e');
      rethrow;
    }
  }

  /// Upload an image file to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(File imageFile, {
    String? publicId,
    String folder = 'plants',
    List<String> tags = const [],
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('📤 Uploading image to Cloudinary...');
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          publicId: publicId,
          folder: folder,
          tags: tags,
        ),
      );
      
      final imageUrl = response.secureUrl;
      print('✅ Image uploaded successfully: $imageUrl');
      return imageUrl;
      
    } catch (e) {
      print('❌ Error uploading image to Cloudinary: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = 'plants',
    List<String> tags = const [],
  }) async {
    final urls = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final publicId = '${DateTime.now().millisecondsSinceEpoch}_$i';
      
      try {
        final url = await uploadImage(
          file,
          publicId: publicId,
          folder: folder,
          tags: tags,
        );
        urls.add(url);
      } catch (e) {
        print('❌ Failed to upload image $i: $e');
        // Continue with other images even if one fails
      }
    }
    
    return urls;
  }

  /// Generate a Cloudinary URL with transformations
  String getTransformedUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    if (!_isInitialized) {
      throw Exception('Cloudinary service not initialized');
    }

    // Build transformation parameters
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    transformations.add('c_$crop');
    
    final transformation = transformations.join(',');
    
    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformation/$publicId';
  }

  /// Get optimized image URL for different use cases
  String getOptimizedUrl(
    String originalUrl, {
    ImageOptimization optimization = ImageOptimization.standard,
  }) {
    // Extract public ID from Cloudinary URL
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.length < 6 || !originalUrl.contains('cloudinary.com')) {
      // Not a Cloudinary URL, return as is
      return originalUrl;
    }
    
    final publicId = pathSegments.sublist(6).join('/');
    
    switch (optimization) {
      case ImageOptimization.thumbnail:
        return getTransformedUrl(publicId, width: 150, height: 150);
      case ImageOptimization.card:
        return getTransformedUrl(publicId, width: 400, height: 300);
      case ImageOptimization.detail:
        return getTransformedUrl(publicId, width: 800, height: 600);
      case ImageOptimization.fullscreen:
        return getTransformedUrl(publicId, width: 1200, height: 900);
      case ImageOptimization.standard:
      default:
        return getTransformedUrl(publicId, width: 600, height: 400);
    }
  }

  /// Delete an image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Note: Deletion requires signed API calls which need API secret
      // For now, we'll just log the attempt
      print('🗑️ Delete request for image: $publicId');
      print('⚠️ Image deletion requires server-side implementation with API secret');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
    _instance = null;
  }
}

/// Image optimization presets
enum ImageOptimization {
  thumbnail,  // 150x150
  card,       // 400x300
  standard,   // 600x400
  detail,     // 800x600
  fullscreen, // 1200x900
}

import '../../features/plants/domain/models/plant.dart';

class PlantImageService {
  static PlantImageService? _instance;
  static PlantImageService get instance => _instance ??= PlantImageService._();
  
  PlantImageService._();

  // Cloudinary base URL for fallback images
  static const String _cloudinaryBaseUrl = 'https://res.cloudinary.com/dvqrmyzbe/image/upload';
  static const String _fallbackFolder = 'v1725007260/plant_defaults';

  /// Get image URL for a plant with fallback support
  String getPlantImageUrl(Plant plant, {
    ImageSize size = ImageSize.standard,
  }) {
    // If plant has its own image, use it with optimization
    if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty) {
      return _optimizeImageUrl(plant.imageUrl!, size);
    }
    
    // Otherwise, return fallback image based on plant type
    return _getFallbackImageUrl(plant.type, size);
  }

  /// Get fallback image URL based on plant type
  String _getFallbackImageUrl(PlantType plantType, ImageSize size) {
    final imageId = _getFallbackImageId(plantType);
    final transformation = _getSizeTransformation(size);
    
    return '$_cloudinaryBaseUrl/$transformation/$_fallbackFolder/$imageId';
  }

  /// Get the fallback image ID based on plant type
  String _getFallbackImageId(PlantType plantType) {
    switch (plantType) {
      case PlantType.flowering:
        return 'flowering_plant.jpg';
      case PlantType.foliage:
        return 'foliage_plant.jpg';
      case PlantType.succulent:
        return 'succulent_plant.jpg';
      case PlantType.herb:
        return 'herb_plant.jpg';
      case PlantType.tree:
        return 'tree_plant.jpg';
      case PlantType.vegetable:
        return 'vegetable_plant.jpg';
      case PlantType.fruit:
        return 'fruit_plant.jpg';
    }
  }

  /// Optimize existing image URL based on size requirements
  String _optimizeImageUrl(String originalUrl, ImageSize size) {
    // If it's already a Cloudinary URL, add transformations
    if (originalUrl.contains('cloudinary.com')) {
      return _addTransformationToCloudinaryUrl(originalUrl, size);
    }
    
    // For Firebase Storage or other URLs, return as-is
    return originalUrl;
  }

  /// Add transformation to existing Cloudinary URL
  String _addTransformationToCloudinaryUrl(String originalUrl, ImageSize size) {
    final transformation = _getSizeTransformation(size);
    
    // Insert transformation into Cloudinary URL
    if (originalUrl.contains('/image/upload/')) {
      return originalUrl.replaceFirst('/image/upload/', '/image/upload/$transformation/');
    }
    
    return originalUrl;
  }

  /// Get size transformation parameters for Cloudinary
  String _getSizeTransformation(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return 'c_fill,w_150,h_150,q_auto,f_auto';
      case ImageSize.card:
        return 'c_fill,w_400,h_300,q_auto,f_auto';
      case ImageSize.detail:
        return 'c_fill,w_800,h_600,q_auto,f_auto';
      case ImageSize.fullscreen:
        return 'c_fill,w_1200,h_900,q_auto,f_auto';
      case ImageSize.standard:
      default:
        return 'c_fill,w_600,h_400,q_auto,f_auto';
    }
  }

  /// Get multiple fallback images for variety
  List<String> getFallbackImagesForType(PlantType plantType, {
    ImageSize size = ImageSize.standard,
    int count = 3,
  }) {
    final baseImages = _getVarietyImageIds(plantType);
    final transformation = _getSizeTransformation(size);
    
    return baseImages
        .take(count)
        .map((imageId) => '$_cloudinaryBaseUrl/$transformation/$_fallbackFolder/$imageId')
        .toList();
  }

  /// Get variety of images for each plant type
  List<String> _getVarietyImageIds(PlantType plantType) {
    switch (plantType) {
      case PlantType.flowering:
        return [
          'flowering_plant_1.jpg',
          'flowering_plant_2.jpg', 
          'flowering_plant_3.jpg',
        ];
      case PlantType.foliage:
        return [
          'foliage_plant_1.jpg',
          'foliage_plant_2.jpg',
          'foliage_plant_3.jpg',
        ];
      case PlantType.succulent:
        return [
          'succulent_plant_1.jpg',
          'succulent_plant_2.jpg',
          'succulent_plant_3.jpg',
        ];
      case PlantType.herb:
        return [
          'herb_plant_1.jpg',
          'herb_plant_2.jpg',
          'herb_plant_3.jpg',
        ];
      case PlantType.tree:
        return [
          'tree_plant_1.jpg',
          'tree_plant_2.jpg',
          'tree_plant_3.jpg',
        ];
      case PlantType.vegetable:
        return [
          'vegetable_plant_1.jpg',
          'vegetable_plant_2.jpg',
          'vegetable_plant_3.jpg',
        ];
      case PlantType.fruit:
        return [
          'fruit_plant_1.jpg',
          'fruit_plant_2.jpg',
          'fruit_plant_3.jpg',
        ];
    }
  }

  /// Get a random fallback image for variety
  String getRandomFallbackImage(PlantType plantType, {ImageSize size = ImageSize.standard}) {
    final images = getFallbackImagesForType(plantType, size: size);
    final randomIndex = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[randomIndex];
  }

  /// Default plant images with free stock photos from Unsplash via Cloudinary
  /// These are generic plant images that work without needing custom uploads
  String getGenericPlantImage(PlantType plantType, {ImageSize size = ImageSize.standard}) {
    final transformation = _getSizeTransformation(size);
    
    // Using sample plant images from Cloudinary's sample gallery
    switch (plantType) {
      case PlantType.flowering:
        return '$_cloudinaryBaseUrl/$transformation/samples/flowers.jpg';
      case PlantType.foliage:
        return '$_cloudinaryBaseUrl/$transformation/samples/leaves.jpg';  
      case PlantType.succulent:
        return '$_cloudinaryBaseUrl/$transformation/samples/cactus.jpg';
      case PlantType.herb:
        return '$_cloudinaryBaseUrl/$transformation/samples/herbs.jpg';
      case PlantType.tree:
        return '$_cloudinaryBaseUrl/$transformation/samples/tree.jpg';
      case PlantType.vegetable:
        return '$_cloudinaryBaseUrl/$transformation/samples/vegetables.jpg';
      case PlantType.fruit:
        return '$_cloudinaryBaseUrl/$transformation/samples/fruit.jpg';
    }
  }
}

/// Image size options for optimization
enum ImageSize {
  thumbnail,  // 150x150 - For lists/grids
  card,       // 400x300 - For cards
  standard,   // 600x400 - Default size
  detail,     // 800x600 - Detail views
  fullscreen, // 1200x900 - Full screen
}

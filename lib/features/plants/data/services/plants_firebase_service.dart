import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/models/plant.dart';

class PlantsFirebaseService {
  static PlantsFirebaseService? _instance;
  static PlantsFirebaseService get instance => _instance ??= PlantsFirebaseService._();
  
  PlantsFirebaseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService.instance;

  /// Get the current user's plants collection reference
  CollectionReference<Map<String, dynamic>> get _plantsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('plants');
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _cloudinaryService.initialize();
    print('✅ Plants Firebase Service initialized');
  }

  /// Add a new plant with image upload to Cloudinary (with Firebase Storage fallback)
  Future<Plant> addPlant(Plant plant, {File? imageFile}) async {
    try {
      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        try {
          print('📤 Trying to upload plant image to Cloudinary...');
          imageUrl = await _cloudinaryService.uploadImage(
            imageFile,
            publicId: 'plant_${plant.id}',
            folder: 'plants',
            tags: ['plant', plant.type.name, plant.species.toLowerCase().replaceAll(' ', '_')],
          );
          print('✅ Cloudinary upload successful');
        } catch (cloudinaryError) {
          print('⚠️ Cloudinary upload failed: $cloudinaryError');
          print('🔄 Falling back to Firebase Storage...');
          
          try {
            // Fallback to Firebase Storage
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('plants')
                .child('${plant.id}.jpg');
            
            final uploadTask = await storageRef.putFile(imageFile);
            imageUrl = await uploadTask.ref.getDownloadURL();
            print('✅ Firebase Storage upload successful');
          } catch (storageError) {
            print('❌ Firebase Storage also failed: $storageError');
            print('📝 Saving plant without image...');
            // Continue without image
          }
        }
      }

      // Create plant with image URL (or null if upload failed)
      final plantWithImage = plant.copyWith(imageUrl: imageUrl);

      // Save to Firestore with manual JSON conversion
      final plantJson = plantWithImage.toJson();
      // Ensure careSchedule is properly serialized
      plantJson['careSchedule'] = plantWithImage.careSchedule.toJson();
      await _plantsCollection.doc(plant.id).set(plantJson);
      
      print('✅ Plant added to Firebase: ${plant.name}');
      return plantWithImage;
    } catch (e) {
      print('❌ Error adding plant to Firebase: $e');
      throw Exception('Failed to add plant: $e');
    }
  }

  /// Update an existing plant
  Future<Plant> updatePlant(Plant plant, {File? newImageFile}) async {
    try {
      Plant updatedPlant = plant;
      
      // Upload new image to Cloudinary if provided
      if (newImageFile != null) {
        print('📤 Uploading updated plant image to Cloudinary...');
        final imageUrl = await _cloudinaryService.uploadImage(
          newImageFile,
          publicId: 'plant_${plant.id}',
          folder: 'plants',
          tags: ['plant', plant.type.name, plant.species.toLowerCase().replaceAll(' ', '_')],
        );
        updatedPlant = plant.copyWith(imageUrl: imageUrl);
      }

      // Update in Firebase with manual JSON conversion
      final plantJson = updatedPlant.toJson();
      // Ensure careSchedule is properly serialized
      plantJson['careSchedule'] = updatedPlant.careSchedule.toJson();
      await _plantsCollection.doc(plant.id).update(plantJson);
      
      print('✅ Plant updated in Firebase: ${plant.name}');
      return updatedPlant;
    } catch (e) {
      print('❌ Error updating plant in Firebase: $e');
      throw Exception('Failed to update plant: $e');
    }
  }

  /// Get all plants for the current user
  Future<List<Plant>> getPlants() async {
    try {
      final snapshot = await _plantsCollection.get();
      final plants = snapshot.docs
          .map((doc) => Plant.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      print('✅ Retrieved ${plants.length} plants from Firebase');
      return plants;
    } catch (e) {
      print('❌ Error getting plants from Firebase: $e');
      throw Exception('Failed to get plants: $e');
    }
  }

  /// Get a specific plant by ID
  Future<Plant?> getPlant(String plantId) async {
    try {
      final doc = await _plantsCollection.doc(plantId).get();
      if (!doc.exists) return null;
      
      return Plant.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('❌ Error getting plant from Firebase: $e');
      throw Exception('Failed to get plant: $e');
    }
  }

  /// Delete a plant
  Future<void> deletePlant(String plantId) async {
    try {
      await _plantsCollection.doc(plantId).delete();
      print('✅ Plant deleted from Firebase: $plantId');
    } catch (e) {
      print('❌ Error deleting plant from Firebase: $e');
      throw Exception('Failed to delete plant: $e');
    }
  }

  /// Get plants as a stream for real-time updates
  Stream<List<Plant>> getPlantsStream() {
    return _plantsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Plant.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Update plant watering status
  Future<void> waterPlant(String plantId) async {
    try {
      await _plantsCollection.doc(plantId).update({
        'lastWatered': Timestamp.now(),
      });
      print('✅ Plant watered: $plantId');
    } catch (e) {
      print('❌ Error watering plant: $e');
      throw Exception('Failed to water plant: $e');
    }
  }

  /// Update plant fertilizing status
  Future<void> fertilizePlant(String plantId) async {
    try {
      await _plantsCollection.doc(plantId).update({
        'lastFertilized': Timestamp.now(),
      });
      print('✅ Plant fertilized: $plantId');
    } catch (e) {
      print('❌ Error fertilizing plant: $e');
      throw Exception('Failed to fertilize plant: $e');
    }
  }

  /// Update plant health status
  Future<void> updatePlantHealth(String plantId, HealthStatus healthStatus) async {
    try {
      await _plantsCollection.doc(plantId).update({
        'healthStatus': healthStatus.name,
      });
      print('✅ Plant health updated: $plantId -> ${healthStatus.displayName}');
    } catch (e) {
      print('❌ Error updating plant health: $e');
      throw Exception('Failed to update plant health: $e');
    }
  }

  /// Get plants that need watering
  Future<List<Plant>> getPlantsNeedingWater() async {
    try {
      final plants = await getPlants();
      final now = DateTime.now();
      
      return plants.where((plant) {
        if (plant.lastWatered == null) return true;
        final daysSinceWatered = now.difference(plant.lastWatered!).inDays;
        return daysSinceWatered >= plant.careSchedule.wateringIntervalDays;
      }).toList();
    } catch (e) {
      print('❌ Error getting plants needing water: $e');
      throw Exception('Failed to get plants needing water: $e');
    }
  }

  /// Get plants that need fertilizing
  Future<List<Plant>> getPlantsNeedingFertilizer() async {
    try {
      final plants = await getPlants();
      final now = DateTime.now();
      
      return plants.where((plant) {
        if (plant.lastFertilized == null) return true;
        final daysSinceFertilized = now.difference(plant.lastFertilized!).inDays;
        return daysSinceFertilized >= plant.careSchedule.fertilizingIntervalDays;
      }).toList();
    } catch (e) {
      print('❌ Error getting plants needing fertilizer: $e');
      throw Exception('Failed to get plants needing fertilizer: $e');
    }
  }

  /// Search plants by name or species
  Future<List<Plant>> searchPlants(String query) async {
    try {
      final plants = await getPlants();
      final lowercaseQuery = query.toLowerCase();
      
      return plants.where((plant) {
        return plant.name.toLowerCase().contains(lowercaseQuery) ||
               plant.species.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('❌ Error searching plants: $e');
      throw Exception('Failed to search plants: $e');
    }
  }

  /// Get plants by type
  Future<List<Plant>> getPlantsByType(PlantType type) async {
    try {
      final plants = await getPlants();
      return plants.where((plant) => plant.type == type).toList();
    } catch (e) {
      print('❌ Error getting plants by type: $e');
      throw Exception('Failed to get plants by type: $e');
    }
  }

  /// Create sample plants in Firebase (for first-time users)
  Future<void> createSamplePlantsIfNeeded() async {
    try {
      final existingPlants = await getPlants();
      if (existingPlants.isNotEmpty) {
        print('User already has plants, skipping sample data creation');
        return;
      }

      print('Creating sample plants for new user...');
      final samplePlants = _getSamplePlants();
      
      for (final plant in samplePlants) {
        final plantJson = plant.toJson();
        // Ensure careSchedule is properly serialized
        plantJson['careSchedule'] = plant.careSchedule.toJson();
        await _plantsCollection.doc(plant.id).set(plantJson);
      }
      
      print('✅ Sample plants created successfully');
    } catch (e) {
      print('❌ Error creating sample plants: $e');
      // Don't throw here, as this is optional
    }
  }

  List<Plant> _getSamplePlants() {
    final now = DateTime.now();
    return [
      Plant(
        id: 'sample_1',
        name: 'Monstera Deliciosa',
        species: 'Monstera deliciosa',
        location: 'Living Room',
        type: PlantType.foliage,
        dateAdded: now.subtract(const Duration(days: 30)),
        careSchedule: const CareSchedule(
          wateringIntervalDays: 7,
          fertilizingIntervalDays: 30,
          repottingIntervalMonths: 12,
          careNotes: ['Prefers bright indirect light', 'Mist leaves regularly'],
        ),
        imageUrl: 'https://res.cloudinary.com/dvqrmyzbe/image/upload/v1/plants/sample/monstera',
        healthStatus: HealthStatus.excellent,
        lastWatered: now.subtract(const Duration(days: 5)),
        lastFertilized: now.subtract(const Duration(days: 15)),
        notes: 'Growing beautifully with new fenestrations!',
      ),
      Plant(
        id: 'sample_2',
        name: 'Snake Plant',
        species: 'Sansevieria trifasciata',
        location: 'Bedroom',
        type: PlantType.foliage,
        dateAdded: now.subtract(const Duration(days: 60)),
        careSchedule: const CareSchedule(
          wateringIntervalDays: 14,
          fertilizingIntervalDays: 60,
          repottingIntervalMonths: 24,
          careNotes: ['Very drought tolerant', 'Avoid overwatering'],
        ),
        imageUrl: 'https://res.cloudinary.com/dvqrmyzbe/image/upload/v1/plants/sample/snake_plant',
        healthStatus: HealthStatus.good,
        lastWatered: now.subtract(const Duration(days: 10)),
        lastFertilized: now.subtract(const Duration(days: 30)),
        notes: 'Perfect for beginners!',
      ),
      Plant(
        id: 'sample_3',
        name: 'Fiddle Leaf Fig',
        species: 'Ficus lyrata',
        location: 'Office',
        type: PlantType.tree,
        dateAdded: now.subtract(const Duration(days: 90)),
        careSchedule: const CareSchedule(
          wateringIntervalDays: 7,
          fertilizingIntervalDays: 21,
          repottingIntervalMonths: 18,
          careNotes: ['Needs bright indirect light', 'Don\'t move frequently'],
        ),
        imageUrl: 'https://res.cloudinary.com/dvqrmyzbe/image/upload/v1/plants/sample/fiddle_leaf_fig',
        healthStatus: HealthStatus.fair,
        lastWatered: now.subtract(const Duration(days: 8)),
        lastFertilized: now.subtract(const Duration(days: 25)),
        notes: 'Needs attention - some brown spots appearing',
      ),
    ];
  }
}

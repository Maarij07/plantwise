import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/plant.dart';
import '../../data/services/plants_firebase_service.dart';

// Firebase service provider
final plantsFirebaseServiceProvider = Provider<PlantsFirebaseService>((ref) {
  return PlantsFirebaseService.instance;
});

// Stream provider for real-time plants data
final plantsStreamProvider = StreamProvider<List<Plant>>((ref) {
  final service = ref.watch(plantsFirebaseServiceProvider);
  return service.getPlantsStream();
});

// State provider for managing plants
final plantsProvider = StateNotifierProvider<PlantsNotifier, AsyncValue<List<Plant>>>((ref) {
  return PlantsNotifier(ref.watch(plantsFirebaseServiceProvider));
});

class PlantsNotifier extends StateNotifier<AsyncValue<List<Plant>>> {
  final PlantsFirebaseService _firebaseService;
  
  PlantsNotifier(this._firebaseService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _firebaseService.initialize();
      await _firebaseService.createSamplePlantsIfNeeded();
      await loadPlants();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Load plants from Firebase
  Future<void> loadPlants() async {
    try {
      state = const AsyncValue.loading();
      final plants = await _firebaseService.getPlants();
      state = AsyncValue.data(plants);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new plant with optional image
  Future<void> addPlant(Plant plant, {File? imageFile}) async {
    try {
      await _firebaseService.addPlant(plant, imageFile: imageFile);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error adding plant: $error');
      rethrow;
    }
  }

  /// Update an existing plant
  Future<void> updatePlant(Plant plant, {File? newImageFile}) async {
    try {
      await _firebaseService.updatePlant(plant, newImageFile: newImageFile);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error updating plant: $error');
      rethrow;
    }
  }

  /// Remove a plant
  Future<void> removePlant(String plantId) async {
    try {
      await _firebaseService.deletePlant(plantId);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error removing plant: $error');
      rethrow;
    }
  }

  /// Mark a plant as watered
  Future<void> waterPlant(String plantId) async {
    try {
      await _firebaseService.waterPlant(plantId);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error watering plant: $error');
      rethrow;
    }
  }

  /// Mark a plant as fertilized
  Future<void> fertilizePlant(String plantId) async {
    try {
      await _firebaseService.fertilizePlant(plantId);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error fertilizing plant: $error');
      rethrow;
    }
  }

  /// Update plant health status
  Future<void> updatePlantHealth(String plantId, HealthStatus healthStatus) async {
    try {
      await _firebaseService.updatePlantHealth(plantId, healthStatus);
      await loadPlants(); // Refresh the list
    } catch (error) {
      print('Error updating plant health: $error');
      rethrow;
    }
  }
}

// Computed providers for Firebase-based plants
final plantsNeedingWaterProvider = FutureProvider<List<Plant>>((ref) async {
  final service = ref.watch(plantsFirebaseServiceProvider);
  return await service.getPlantsNeedingWater();
});

final plantsNeedingFertilizerProvider = FutureProvider<List<Plant>>((ref) async {
  final service = ref.watch(plantsFirebaseServiceProvider);
  return await service.getPlantsNeedingFertilizer();
});

final plantsByTypeProvider = Provider<Map<PlantType, List<Plant>>>((ref) {
  final asyncPlants = ref.watch(plantsProvider);
  final plantsByType = <PlantType, List<Plant>>{};
  
  asyncPlants.whenData((plants) {
    for (final plant in plants) {
      plantsByType.putIfAbsent(plant.type, () => []).add(plant);
    }
  });
  
  return plantsByType;
});

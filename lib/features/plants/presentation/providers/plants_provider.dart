import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/plant.dart';

final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((ref) {
  return PlantsNotifier();
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  PlantsNotifier() : super([]) {
    _loadPlants();
  }

  static const String _plantsKey = 'plants';

  Future<void> _loadPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final plantsJson = prefs.getStringList(_plantsKey);
    
    if (plantsJson != null) {
      state = plantsJson
          .map((json) => Plant.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // Initialize with sample data
      state = _getSamplePlants();
      await _savePlants();
    }
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    final plantsJson = state
        .map((plant) => jsonEncode(plant.toJson()))
        .toList();
    await prefs.setStringList(_plantsKey, plantsJson);
  }

  Future<void> addPlant(Plant plant) async {
    state = [...state, plant];
    await _savePlants();
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    state = state.map((plant) {
      if (plant.id == updatedPlant.id) {
        return updatedPlant;
      }
      return plant;
    }).toList();
    await _savePlants();
  }

  Future<void> removePlant(String plantId) async {
    state = state.where((plant) => plant.id != plantId).toList();
    await _savePlants();
  }

  Future<void> waterPlant(String plantId) async {
    final now = DateTime.now();
    state = state.map((plant) {
      if (plant.id == plantId) {
        return plant.copyWith(lastWatered: now);
      }
      return plant;
    }).toList();
    await _savePlants();
  }

  Future<void> fertilizePlant(String plantId) async {
    final now = DateTime.now();
    state = state.map((plant) {
      if (plant.id == plantId) {
        return plant.copyWith(lastFertilized: now);
      }
      return plant;
    }).toList();
    await _savePlants();
  }

  List<Plant> getPlantsNeedingWater() {
    final now = DateTime.now();
    return state.where((plant) {
      if (plant.lastWatered == null) return true;
      final daysSinceWatered = now.difference(plant.lastWatered!).inDays;
      return daysSinceWatered >= plant.careSchedule.wateringIntervalDays;
    }).toList();
  }

  List<Plant> getPlantsNeedingFertilizer() {
    final now = DateTime.now();
    return state.where((plant) {
      if (plant.lastFertilized == null) return true;
      final daysSinceFertilized = now.difference(plant.lastFertilized!).inDays;
      return daysSinceFertilized >= plant.careSchedule.fertilizingIntervalDays;
    }).toList();
  }

  List<Plant> _getSamplePlants() {
    final now = DateTime.now();
    return [
      Plant(
        id: '1',
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
        healthStatus: HealthStatus.excellent,
        lastWatered: now.subtract(const Duration(days: 5)),
        lastFertilized: now.subtract(const Duration(days: 15)),
        notes: 'Growing beautifully with new fenestrations!',
      ),
      Plant(
        id: '2',
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
        healthStatus: HealthStatus.good,
        lastWatered: now.subtract(const Duration(days: 10)),
        lastFertilized: now.subtract(const Duration(days: 30)),
        notes: 'Perfect for beginners!',
      ),
      Plant(
        id: '3',
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
        healthStatus: HealthStatus.fair,
        lastWatered: now.subtract(const Duration(days: 8)),
        lastFertilized: now.subtract(const Duration(days: 25)),
        notes: 'Needs attention - some brown spots appearing',
      ),
    ];
  }
}

// Computed providers
final plantsNeedingWaterProvider = Provider<List<Plant>>((ref) {
  final plantsNotifier = ref.watch(plantsProvider.notifier);
  return plantsNotifier.getPlantsNeedingWater();
});

final plantsNeedingFertilizerProvider = Provider<List<Plant>>((ref) {
  final plantsNotifier = ref.watch(plantsProvider.notifier);
  return plantsNotifier.getPlantsNeedingFertilizer();
});

final plantsByTypeProvider = Provider<Map<PlantType, List<Plant>>>((ref) {
  final plants = ref.watch(plantsProvider);
  final plantsByType = <PlantType, List<Plant>>{};
  
  for (final plant in plants) {
    plantsByType.putIfAbsent(plant.type, () => []).add(plant);
  }
  
  return plantsByType;
});

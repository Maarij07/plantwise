import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant.freezed.dart';
part 'plant.g.dart';

@freezed
class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String name,
    required String species,
    required String location,
    required PlantType type,
    required DateTime dateAdded,
    required CareSchedule careSchedule,
    String? imageUrl,
    String? notes,
    HealthStatus? healthStatus,
    DateTime? lastWatered,
    DateTime? lastFertilized,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

@freezed
class CareSchedule with _$CareSchedule {
  const factory CareSchedule({
    required int wateringIntervalDays,
    required int fertilizingIntervalDays,
    int? repottingIntervalMonths,
    List<String>? careNotes,
  }) = _CareSchedule;

  factory CareSchedule.fromJson(Map<String, dynamic> json) => 
      _$CareScheduleFromJson(json);
}

enum PlantType {
  flowering('Flowering', Icons.local_florist),
  foliage('Foliage', Icons.eco),
  succulent('Succulent', Icons.grass),
  herb('Herb', Icons.spa),
  tree('Tree', Icons.park),
  vegetable('Vegetable', Icons.eco),
  fruit('Fruit', Icons.apple);

  const PlantType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;
}

enum HealthStatus {
  excellent('Excellent', Color(0xFF2E7D32)),
  good('Good', Color(0xFF8BC34A)),
  fair('Fair', Color(0xFFF57C00)),
  poor('Poor', Color(0xFFD32F2F)),
  critical('Critical', Color(0xFFB71C1C));

  const HealthStatus(this.displayName, this.color);

  final String displayName;
  final Color color;
}

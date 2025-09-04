// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlantImpl _$$PlantImplFromJson(Map<String, dynamic> json) => _$PlantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      location: json['location'] as String,
      type: $enumDecode(_$PlantTypeEnumMap, json['type']),
      dateAdded: const TimestampConverter().fromJson(json['dateAdded']),
      careSchedule:
          CareSchedule.fromJson(json['careSchedule'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      healthStatus:
          $enumDecodeNullable(_$HealthStatusEnumMap, json['healthStatus']),
      lastWatered:
          const NullableTimestampConverter().fromJson(json['lastWatered']),
      lastFertilized:
          const NullableTimestampConverter().fromJson(json['lastFertilized']),
    );

Map<String, dynamic> _$$PlantImplToJson(_$PlantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'location': instance.location,
      'type': _$PlantTypeEnumMap[instance.type]!,
      'dateAdded': const TimestampConverter().toJson(instance.dateAdded),
      'careSchedule': instance.careSchedule,
      'imageUrl': instance.imageUrl,
      'notes': instance.notes,
      'healthStatus': _$HealthStatusEnumMap[instance.healthStatus],
      'lastWatered':
          const NullableTimestampConverter().toJson(instance.lastWatered),
      'lastFertilized':
          const NullableTimestampConverter().toJson(instance.lastFertilized),
    };

const _$PlantTypeEnumMap = {
  PlantType.flowering: 'flowering',
  PlantType.foliage: 'foliage',
  PlantType.succulent: 'succulent',
  PlantType.herb: 'herb',
  PlantType.tree: 'tree',
  PlantType.vegetable: 'vegetable',
  PlantType.fruit: 'fruit',
};

const _$HealthStatusEnumMap = {
  HealthStatus.excellent: 'excellent',
  HealthStatus.good: 'good',
  HealthStatus.fair: 'fair',
  HealthStatus.poor: 'poor',
  HealthStatus.critical: 'critical',
};

_$CareScheduleImpl _$$CareScheduleImplFromJson(Map<String, dynamic> json) =>
    _$CareScheduleImpl(
      wateringIntervalDays: (json['wateringIntervalDays'] as num).toInt(),
      fertilizingIntervalDays: (json['fertilizingIntervalDays'] as num).toInt(),
      repottingIntervalMonths:
          (json['repottingIntervalMonths'] as num?)?.toInt(),
      careNotes: (json['careNotes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CareScheduleImplToJson(_$CareScheduleImpl instance) =>
    <String, dynamic>{
      'wateringIntervalDays': instance.wateringIntervalDays,
      'fertilizingIntervalDays': instance.fertilizingIntervalDays,
      'repottingIntervalMonths': instance.repottingIntervalMonths,
      'careNotes': instance.careNotes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      plantName: json['plantName'] as String,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isCompleted: json['isCompleted'] as bool?,
      notes: json['notes'] as String?,
      frequency:
          $enumDecodeNullable(_$ReminderFrequencyEnumMap, json['frequency']),
      nextScheduledDate: json['nextScheduledDate'] == null
          ? null
          : DateTime.parse(json['nextScheduledDate'] as String),
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'plantName': instance.plantName,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'notes': instance.notes,
      'frequency': _$ReminderFrequencyEnumMap[instance.frequency],
      'nextScheduledDate': instance.nextScheduledDate?.toIso8601String(),
    };

const _$ReminderTypeEnumMap = {
  ReminderType.watering: 'watering',
  ReminderType.fertilizing: 'fertilizing',
  ReminderType.repotting: 'repotting',
  ReminderType.pruning: 'pruning',
  ReminderType.inspection: 'inspection',
  ReminderType.custom: 'custom',
};

const _$ReminderFrequencyEnumMap = {
  ReminderFrequency.daily: 'daily',
  ReminderFrequency.weekly: 'weekly',
  ReminderFrequency.biweekly: 'biweekly',
  ReminderFrequency.monthly: 'monthly',
  ReminderFrequency.quarterly: 'quarterly',
  ReminderFrequency.yearly: 'yearly',
  ReminderFrequency.custom: 'custom',
};

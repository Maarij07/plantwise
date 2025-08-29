// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease_detection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiseaseDetectionResultImpl _$$DiseaseDetectionResultImplFromJson(
        Map<String, dynamic> json) =>
    _$DiseaseDetectionResultImpl(
      detections: (json['detections'] as List<dynamic>)
          .map((e) => DetectedDisease.fromJson(e as Map<String, dynamic>))
          .toList(),
      processingTimeMs: (json['processingTimeMs'] as num).toDouble(),
      imageWidth: (json['imageWidth'] as num).toInt(),
      imageHeight: (json['imageHeight'] as num).toInt(),
      modelVersion: json['modelVersion'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$DiseaseDetectionResultImplToJson(
        _$DiseaseDetectionResultImpl instance) =>
    <String, dynamic>{
      'detections': instance.detections,
      'processingTimeMs': instance.processingTimeMs,
      'imageWidth': instance.imageWidth,
      'imageHeight': instance.imageHeight,
      'modelVersion': instance.modelVersion,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$DetectedDiseaseImpl _$$DetectedDiseaseImplFromJson(
        Map<String, dynamic> json) =>
    _$DetectedDiseaseImpl(
      diseaseClass: json['diseaseClass'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox:
          BoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>),
      description: json['description'] as String?,
      severity: json['severity'] as String?,
      treatmentSuggestions: (json['treatmentSuggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preventionTips: (json['preventionTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DetectedDiseaseImplToJson(
        _$DetectedDiseaseImpl instance) =>
    <String, dynamic>{
      'diseaseClass': instance.diseaseClass,
      'diseaseName': instance.diseaseName,
      'confidence': instance.confidence,
      'boundingBox': instance.boundingBox,
      'description': instance.description,
      'severity': instance.severity,
      'treatmentSuggestions': instance.treatmentSuggestions,
      'preventionTips': instance.preventionTips,
    };

_$BoundingBoxImpl _$$BoundingBoxImplFromJson(Map<String, dynamic> json) =>
    _$BoundingBoxImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$BoundingBoxImplToJson(_$BoundingBoxImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

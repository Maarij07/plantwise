import 'package:freezed_annotation/freezed_annotation.dart';

part 'disease_detection.freezed.dart';
part 'disease_detection.g.dart';

@freezed
class DiseaseDetectionResult with _$DiseaseDetectionResult {
  const factory DiseaseDetectionResult({
    required List<DetectedDisease> detections,
    required double processingTimeMs,
    required int imageWidth,
    required int imageHeight,
    String? modelVersion,
    DateTime? timestamp,
  }) = _DiseaseDetectionResult;

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionResultFromJson(json);
}

@freezed
class DetectedDisease with _$DetectedDisease {
  const factory DetectedDisease({
    required String diseaseClass,
    required String diseaseName,
    required double confidence,
    required BoundingBox boundingBox,
    String? description,
    String? severity,
    List<String>? treatmentSuggestions,
    List<String>? preventionTips,
  }) = _DetectedDisease;

  factory DetectedDisease.fromJson(Map<String, dynamic> json) =>
      _$DetectedDiseaseFromJson(json);
}

@freezed
class BoundingBox with _$BoundingBox {
  const factory BoundingBox({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);
}

// Extension to add computed properties
extension DetectedDiseaseExtension on DetectedDisease {
  bool get isHealthy => diseaseClass.toLowerCase().contains('leaf') && 
                       !diseaseClass.toLowerCase().contains('spot') &&
                       !diseaseClass.toLowerCase().contains('blight') &&
                       !diseaseClass.toLowerCase().contains('rust') &&
                       !diseaseClass.toLowerCase().contains('mildew') &&
                       !diseaseClass.toLowerCase().contains('virus') &&
                       !diseaseClass.toLowerCase().contains('bacterial') &&
                       !diseaseClass.toLowerCase().contains('mold') &&
                       !diseaseClass.toLowerCase().contains('rot');

  DiseaseSeverityLevel get severityLevel {
    if (confidence < 0.3) return DiseaseSeverityLevel.uncertain;
    if (confidence < 0.5) return DiseaseSeverityLevel.mild;
    if (confidence < 0.7) return DiseaseSeverityLevel.moderate;
    if (confidence < 0.9) return DiseaseSeverityLevel.severe;
    return DiseaseSeverityLevel.critical;
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  String get plantType {
    final lowerClass = diseaseClass.toLowerCase();
    if (lowerClass.contains('apple')) return 'Apple';
    if (lowerClass.contains('tomato')) return 'Tomato';
    if (lowerClass.contains('potato')) return 'Potato';
    if (lowerClass.contains('corn')) return 'Corn';
    if (lowerClass.contains('bell_pepper') || lowerClass.contains('pepper')) return 'Bell Pepper';
    if (lowerClass.contains('grape')) return 'Grape';
    if (lowerClass.contains('strawberry')) return 'Strawberry';
    if (lowerClass.contains('peach')) return 'Peach';
    if (lowerClass.contains('cherry')) return 'Cherry';
    if (lowerClass.contains('blueberry')) return 'Blueberry';
    if (lowerClass.contains('raspberry')) return 'Raspberry';
    if (lowerClass.contains('squash')) return 'Squash';
    if (lowerClass.contains('soyabean') || lowerClass.contains('soya')) return 'Soybean';
    return 'Unknown';
  }
}

enum DiseaseSeverityLevel {
  uncertain('Uncertain', 0),
  mild('Mild', 1),
  moderate('Moderate', 2),
  severe('Severe', 3),
  critical('Critical', 4);

  const DiseaseSeverityLevel(this.displayName, this.level);

  final String displayName;
  final int level;
}

// Helper class for disease information database
class DiseaseInfo {
  static const Map<String, Map<String, dynamic>> diseaseDatabase = {
    'Apple Scab Leaf': {
      'description': 'Apple scab is a fungal disease that causes dark, scabby spots on leaves and fruit.',
      'severity': 'Moderate',
      'treatments': [
        'Apply fungicide sprays during the growing season',
        'Remove fallen leaves to reduce overwintering spores',
        'Prune to improve air circulation',
        'Plant resistant varieties',
      ],
      'prevention': [
        'Choose scab-resistant apple varieties',
        'Maintain good air circulation',
        'Clean up fallen leaves and fruit',
        'Apply preventive fungicide treatments',
      ],
    },
    'Tomato Early blight leaf': {
      'description': 'Early blight is a fungal disease causing brown spots with concentric rings on lower leaves.',
      'severity': 'Moderate',
      'treatments': [
        'Remove affected leaves immediately',
        'Apply copper-based fungicides',
        'Improve air circulation around plants',
        'Water at soil level to avoid wetting leaves',
      ],
      'prevention': [
        'Rotate crops annually',
        'Mulch around plants to prevent soil splash',
        'Provide adequate spacing between plants',
        'Water at the base of plants',
      ],
    },
    'Tomato leaf late blight': {
      'description': 'Late blight is a serious fungal disease that can destroy entire tomato crops rapidly.',
      'severity': 'Critical',
      'treatments': [
        'Remove and destroy all affected plant parts',
        'Apply fungicides containing copper or mancozeb',
        'Improve air circulation',
        'Consider destroying severely affected plants',
      ],
      'prevention': [
        'Plant in well-draining soil',
        'Avoid overhead watering',
        'Ensure good air circulation',
        'Monitor weather conditions (cool, wet weather favors disease)',
      ],
    },
    // Add more disease info as needed...
  };

  static Map<String, dynamic>? getDiseaseInfo(String diseaseClass) {
    return diseaseDatabase[diseaseClass];
  }

  static List<String> getTreatmentSuggestions(String diseaseClass) {
    final info = getDiseaseInfo(diseaseClass);
    return info?['treatments']?.cast<String>() ?? [];
  }

  static List<String> getPreventionTips(String diseaseClass) {
    final info = getDiseaseInfo(diseaseClass);
    return info?['prevention']?.cast<String>() ?? [];
  }

  static String getDescription(String diseaseClass) {
    final info = getDiseaseInfo(diseaseClass);
    return info?['description'] ?? 'Disease information not available.';
  }

  static String getSeverity(String diseaseClass) {
    final info = getDiseaseInfo(diseaseClass);
    return info?['severity'] ?? 'Unknown';
  }
}

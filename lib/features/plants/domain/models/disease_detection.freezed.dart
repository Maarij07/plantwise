// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'disease_detection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiseaseDetectionResult _$DiseaseDetectionResultFromJson(
    Map<String, dynamic> json) {
  return _DiseaseDetectionResult.fromJson(json);
}

/// @nodoc
mixin _$DiseaseDetectionResult {
  List<DetectedDisease> get detections => throw _privateConstructorUsedError;
  double get processingTimeMs => throw _privateConstructorUsedError;
  int get imageWidth => throw _privateConstructorUsedError;
  int get imageHeight => throw _privateConstructorUsedError;
  String? get modelVersion => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this DiseaseDetectionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiseaseDetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiseaseDetectionResultCopyWith<DiseaseDetectionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiseaseDetectionResultCopyWith<$Res> {
  factory $DiseaseDetectionResultCopyWith(DiseaseDetectionResult value,
          $Res Function(DiseaseDetectionResult) then) =
      _$DiseaseDetectionResultCopyWithImpl<$Res, DiseaseDetectionResult>;
  @useResult
  $Res call(
      {List<DetectedDisease> detections,
      double processingTimeMs,
      int imageWidth,
      int imageHeight,
      String? modelVersion,
      DateTime? timestamp});
}

/// @nodoc
class _$DiseaseDetectionResultCopyWithImpl<$Res,
        $Val extends DiseaseDetectionResult>
    implements $DiseaseDetectionResultCopyWith<$Res> {
  _$DiseaseDetectionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiseaseDetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detections = null,
    Object? processingTimeMs = null,
    Object? imageWidth = null,
    Object? imageHeight = null,
    Object? modelVersion = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      detections: null == detections
          ? _value.detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<DetectedDisease>,
      processingTimeMs: null == processingTimeMs
          ? _value.processingTimeMs
          : processingTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      imageWidth: null == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int,
      imageHeight: null == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int,
      modelVersion: freezed == modelVersion
          ? _value.modelVersion
          : modelVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiseaseDetectionResultImplCopyWith<$Res>
    implements $DiseaseDetectionResultCopyWith<$Res> {
  factory _$$DiseaseDetectionResultImplCopyWith(
          _$DiseaseDetectionResultImpl value,
          $Res Function(_$DiseaseDetectionResultImpl) then) =
      __$$DiseaseDetectionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DetectedDisease> detections,
      double processingTimeMs,
      int imageWidth,
      int imageHeight,
      String? modelVersion,
      DateTime? timestamp});
}

/// @nodoc
class __$$DiseaseDetectionResultImplCopyWithImpl<$Res>
    extends _$DiseaseDetectionResultCopyWithImpl<$Res,
        _$DiseaseDetectionResultImpl>
    implements _$$DiseaseDetectionResultImplCopyWith<$Res> {
  __$$DiseaseDetectionResultImplCopyWithImpl(
      _$DiseaseDetectionResultImpl _value,
      $Res Function(_$DiseaseDetectionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiseaseDetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detections = null,
    Object? processingTimeMs = null,
    Object? imageWidth = null,
    Object? imageHeight = null,
    Object? modelVersion = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_$DiseaseDetectionResultImpl(
      detections: null == detections
          ? _value._detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<DetectedDisease>,
      processingTimeMs: null == processingTimeMs
          ? _value.processingTimeMs
          : processingTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      imageWidth: null == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int,
      imageHeight: null == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int,
      modelVersion: freezed == modelVersion
          ? _value.modelVersion
          : modelVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiseaseDetectionResultImpl implements _DiseaseDetectionResult {
  const _$DiseaseDetectionResultImpl(
      {required final List<DetectedDisease> detections,
      required this.processingTimeMs,
      required this.imageWidth,
      required this.imageHeight,
      this.modelVersion,
      this.timestamp})
      : _detections = detections;

  factory _$DiseaseDetectionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiseaseDetectionResultImplFromJson(json);

  final List<DetectedDisease> _detections;
  @override
  List<DetectedDisease> get detections {
    if (_detections is EqualUnmodifiableListView) return _detections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detections);
  }

  @override
  final double processingTimeMs;
  @override
  final int imageWidth;
  @override
  final int imageHeight;
  @override
  final String? modelVersion;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'DiseaseDetectionResult(detections: $detections, processingTimeMs: $processingTimeMs, imageWidth: $imageWidth, imageHeight: $imageHeight, modelVersion: $modelVersion, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiseaseDetectionResultImpl &&
            const DeepCollectionEquality()
                .equals(other._detections, _detections) &&
            (identical(other.processingTimeMs, processingTimeMs) ||
                other.processingTimeMs == processingTimeMs) &&
            (identical(other.imageWidth, imageWidth) ||
                other.imageWidth == imageWidth) &&
            (identical(other.imageHeight, imageHeight) ||
                other.imageHeight == imageHeight) &&
            (identical(other.modelVersion, modelVersion) ||
                other.modelVersion == modelVersion) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_detections),
      processingTimeMs,
      imageWidth,
      imageHeight,
      modelVersion,
      timestamp);

  /// Create a copy of DiseaseDetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiseaseDetectionResultImplCopyWith<_$DiseaseDetectionResultImpl>
      get copyWith => __$$DiseaseDetectionResultImplCopyWithImpl<
          _$DiseaseDetectionResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiseaseDetectionResultImplToJson(
      this,
    );
  }
}

abstract class _DiseaseDetectionResult implements DiseaseDetectionResult {
  const factory _DiseaseDetectionResult(
      {required final List<DetectedDisease> detections,
      required final double processingTimeMs,
      required final int imageWidth,
      required final int imageHeight,
      final String? modelVersion,
      final DateTime? timestamp}) = _$DiseaseDetectionResultImpl;

  factory _DiseaseDetectionResult.fromJson(Map<String, dynamic> json) =
      _$DiseaseDetectionResultImpl.fromJson;

  @override
  List<DetectedDisease> get detections;
  @override
  double get processingTimeMs;
  @override
  int get imageWidth;
  @override
  int get imageHeight;
  @override
  String? get modelVersion;
  @override
  DateTime? get timestamp;

  /// Create a copy of DiseaseDetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiseaseDetectionResultImplCopyWith<_$DiseaseDetectionResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DetectedDisease _$DetectedDiseaseFromJson(Map<String, dynamic> json) {
  return _DetectedDisease.fromJson(json);
}

/// @nodoc
mixin _$DetectedDisease {
  String get diseaseClass => throw _privateConstructorUsedError;
  String get diseaseName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  BoundingBox get boundingBox => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;
  List<String>? get treatmentSuggestions => throw _privateConstructorUsedError;
  List<String>? get preventionTips => throw _privateConstructorUsedError;

  /// Serializes this DetectedDisease to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectedDiseaseCopyWith<DetectedDisease> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectedDiseaseCopyWith<$Res> {
  factory $DetectedDiseaseCopyWith(
          DetectedDisease value, $Res Function(DetectedDisease) then) =
      _$DetectedDiseaseCopyWithImpl<$Res, DetectedDisease>;
  @useResult
  $Res call(
      {String diseaseClass,
      String diseaseName,
      double confidence,
      BoundingBox boundingBox,
      String? description,
      String? severity,
      List<String>? treatmentSuggestions,
      List<String>? preventionTips});

  $BoundingBoxCopyWith<$Res> get boundingBox;
}

/// @nodoc
class _$DetectedDiseaseCopyWithImpl<$Res, $Val extends DetectedDisease>
    implements $DetectedDiseaseCopyWith<$Res> {
  _$DetectedDiseaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diseaseClass = null,
    Object? diseaseName = null,
    Object? confidence = null,
    Object? boundingBox = null,
    Object? description = freezed,
    Object? severity = freezed,
    Object? treatmentSuggestions = freezed,
    Object? preventionTips = freezed,
  }) {
    return _then(_value.copyWith(
      diseaseClass: null == diseaseClass
          ? _value.diseaseClass
          : diseaseClass // ignore: cast_nullable_to_non_nullable
              as String,
      diseaseName: null == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      boundingBox: null == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as BoundingBox,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatmentSuggestions: freezed == treatmentSuggestions
          ? _value.treatmentSuggestions
          : treatmentSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      preventionTips: freezed == preventionTips
          ? _value.preventionTips
          : preventionTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BoundingBoxCopyWith<$Res> get boundingBox {
    return $BoundingBoxCopyWith<$Res>(_value.boundingBox, (value) {
      return _then(_value.copyWith(boundingBox: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DetectedDiseaseImplCopyWith<$Res>
    implements $DetectedDiseaseCopyWith<$Res> {
  factory _$$DetectedDiseaseImplCopyWith(_$DetectedDiseaseImpl value,
          $Res Function(_$DetectedDiseaseImpl) then) =
      __$$DetectedDiseaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String diseaseClass,
      String diseaseName,
      double confidence,
      BoundingBox boundingBox,
      String? description,
      String? severity,
      List<String>? treatmentSuggestions,
      List<String>? preventionTips});

  @override
  $BoundingBoxCopyWith<$Res> get boundingBox;
}

/// @nodoc
class __$$DetectedDiseaseImplCopyWithImpl<$Res>
    extends _$DetectedDiseaseCopyWithImpl<$Res, _$DetectedDiseaseImpl>
    implements _$$DetectedDiseaseImplCopyWith<$Res> {
  __$$DetectedDiseaseImplCopyWithImpl(
      _$DetectedDiseaseImpl _value, $Res Function(_$DetectedDiseaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diseaseClass = null,
    Object? diseaseName = null,
    Object? confidence = null,
    Object? boundingBox = null,
    Object? description = freezed,
    Object? severity = freezed,
    Object? treatmentSuggestions = freezed,
    Object? preventionTips = freezed,
  }) {
    return _then(_$DetectedDiseaseImpl(
      diseaseClass: null == diseaseClass
          ? _value.diseaseClass
          : diseaseClass // ignore: cast_nullable_to_non_nullable
              as String,
      diseaseName: null == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      boundingBox: null == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as BoundingBox,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatmentSuggestions: freezed == treatmentSuggestions
          ? _value._treatmentSuggestions
          : treatmentSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      preventionTips: freezed == preventionTips
          ? _value._preventionTips
          : preventionTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectedDiseaseImpl implements _DetectedDisease {
  const _$DetectedDiseaseImpl(
      {required this.diseaseClass,
      required this.diseaseName,
      required this.confidence,
      required this.boundingBox,
      this.description,
      this.severity,
      final List<String>? treatmentSuggestions,
      final List<String>? preventionTips})
      : _treatmentSuggestions = treatmentSuggestions,
        _preventionTips = preventionTips;

  factory _$DetectedDiseaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectedDiseaseImplFromJson(json);

  @override
  final String diseaseClass;
  @override
  final String diseaseName;
  @override
  final double confidence;
  @override
  final BoundingBox boundingBox;
  @override
  final String? description;
  @override
  final String? severity;
  final List<String>? _treatmentSuggestions;
  @override
  List<String>? get treatmentSuggestions {
    final value = _treatmentSuggestions;
    if (value == null) return null;
    if (_treatmentSuggestions is EqualUnmodifiableListView)
      return _treatmentSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _preventionTips;
  @override
  List<String>? get preventionTips {
    final value = _preventionTips;
    if (value == null) return null;
    if (_preventionTips is EqualUnmodifiableListView) return _preventionTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DetectedDisease(diseaseClass: $diseaseClass, diseaseName: $diseaseName, confidence: $confidence, boundingBox: $boundingBox, description: $description, severity: $severity, treatmentSuggestions: $treatmentSuggestions, preventionTips: $preventionTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectedDiseaseImpl &&
            (identical(other.diseaseClass, diseaseClass) ||
                other.diseaseClass == diseaseClass) &&
            (identical(other.diseaseName, diseaseName) ||
                other.diseaseName == diseaseName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.boundingBox, boundingBox) ||
                other.boundingBox == boundingBox) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality()
                .equals(other._treatmentSuggestions, _treatmentSuggestions) &&
            const DeepCollectionEquality()
                .equals(other._preventionTips, _preventionTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      diseaseClass,
      diseaseName,
      confidence,
      boundingBox,
      description,
      severity,
      const DeepCollectionEquality().hash(_treatmentSuggestions),
      const DeepCollectionEquality().hash(_preventionTips));

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectedDiseaseImplCopyWith<_$DetectedDiseaseImpl> get copyWith =>
      __$$DetectedDiseaseImplCopyWithImpl<_$DetectedDiseaseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectedDiseaseImplToJson(
      this,
    );
  }
}

abstract class _DetectedDisease implements DetectedDisease {
  const factory _DetectedDisease(
      {required final String diseaseClass,
      required final String diseaseName,
      required final double confidence,
      required final BoundingBox boundingBox,
      final String? description,
      final String? severity,
      final List<String>? treatmentSuggestions,
      final List<String>? preventionTips}) = _$DetectedDiseaseImpl;

  factory _DetectedDisease.fromJson(Map<String, dynamic> json) =
      _$DetectedDiseaseImpl.fromJson;

  @override
  String get diseaseClass;
  @override
  String get diseaseName;
  @override
  double get confidence;
  @override
  BoundingBox get boundingBox;
  @override
  String? get description;
  @override
  String? get severity;
  @override
  List<String>? get treatmentSuggestions;
  @override
  List<String>? get preventionTips;

  /// Create a copy of DetectedDisease
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectedDiseaseImplCopyWith<_$DetectedDiseaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) {
  return _BoundingBox.fromJson(json);
}

/// @nodoc
mixin _$BoundingBox {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this BoundingBox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoundingBoxCopyWith<BoundingBox> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoundingBoxCopyWith<$Res> {
  factory $BoundingBoxCopyWith(
          BoundingBox value, $Res Function(BoundingBox) then) =
      _$BoundingBoxCopyWithImpl<$Res, BoundingBox>;
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res, $Val extends BoundingBox>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoundingBoxImplCopyWith<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  factory _$$BoundingBoxImplCopyWith(
          _$BoundingBoxImpl value, $Res Function(_$BoundingBoxImpl) then) =
      __$$BoundingBoxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class __$$BoundingBoxImplCopyWithImpl<$Res>
    extends _$BoundingBoxCopyWithImpl<$Res, _$BoundingBoxImpl>
    implements _$$BoundingBoxImplCopyWith<$Res> {
  __$$BoundingBoxImplCopyWithImpl(
      _$BoundingBoxImpl _value, $Res Function(_$BoundingBoxImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_$BoundingBoxImpl(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoundingBoxImpl implements _BoundingBox {
  const _$BoundingBoxImpl(
      {required this.x,
      required this.y,
      required this.width,
      required this.height});

  factory _$BoundingBoxImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoundingBoxImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoundingBoxImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, width, height);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      __$$BoundingBoxImplCopyWithImpl<_$BoundingBoxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoundingBoxImplToJson(
      this,
    );
  }
}

abstract class _BoundingBox implements BoundingBox {
  const factory _BoundingBox(
      {required final double x,
      required final double y,
      required final double width,
      required final double height}) = _$BoundingBoxImpl;

  factory _BoundingBox.fromJson(Map<String, dynamic> json) =
      _$BoundingBoxImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

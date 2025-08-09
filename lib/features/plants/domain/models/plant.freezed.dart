// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Plant _$PlantFromJson(Map<String, dynamic> json) {
  return _Plant.fromJson(json);
}

/// @nodoc
mixin _$Plant {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get species => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  PlantType get type => throw _privateConstructorUsedError;
  DateTime get dateAdded => throw _privateConstructorUsedError;
  CareSchedule get careSchedule => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  HealthStatus? get healthStatus => throw _privateConstructorUsedError;
  DateTime? get lastWatered => throw _privateConstructorUsedError;
  DateTime? get lastFertilized => throw _privateConstructorUsedError;

  /// Serializes this Plant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantCopyWith<Plant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCopyWith<$Res> {
  factory $PlantCopyWith(Plant value, $Res Function(Plant) then) =
      _$PlantCopyWithImpl<$Res, Plant>;
  @useResult
  $Res call(
      {String id,
      String name,
      String species,
      String location,
      PlantType type,
      DateTime dateAdded,
      CareSchedule careSchedule,
      String? imageUrl,
      String? notes,
      HealthStatus? healthStatus,
      DateTime? lastWatered,
      DateTime? lastFertilized});

  $CareScheduleCopyWith<$Res> get careSchedule;
}

/// @nodoc
class _$PlantCopyWithImpl<$Res, $Val extends Plant>
    implements $PlantCopyWith<$Res> {
  _$PlantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? species = null,
    Object? location = null,
    Object? type = null,
    Object? dateAdded = null,
    Object? careSchedule = null,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? healthStatus = freezed,
    Object? lastWatered = freezed,
    Object? lastFertilized = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      species: null == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlantType,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      careSchedule: null == careSchedule
          ? _value.careSchedule
          : careSchedule // ignore: cast_nullable_to_non_nullable
              as CareSchedule,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      healthStatus: freezed == healthStatus
          ? _value.healthStatus
          : healthStatus // ignore: cast_nullable_to_non_nullable
              as HealthStatus?,
      lastWatered: freezed == lastWatered
          ? _value.lastWatered
          : lastWatered // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastFertilized: freezed == lastFertilized
          ? _value.lastFertilized
          : lastFertilized // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CareScheduleCopyWith<$Res> get careSchedule {
    return $CareScheduleCopyWith<$Res>(_value.careSchedule, (value) {
      return _then(_value.copyWith(careSchedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlantImplCopyWith<$Res> implements $PlantCopyWith<$Res> {
  factory _$$PlantImplCopyWith(
          _$PlantImpl value, $Res Function(_$PlantImpl) then) =
      __$$PlantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String species,
      String location,
      PlantType type,
      DateTime dateAdded,
      CareSchedule careSchedule,
      String? imageUrl,
      String? notes,
      HealthStatus? healthStatus,
      DateTime? lastWatered,
      DateTime? lastFertilized});

  @override
  $CareScheduleCopyWith<$Res> get careSchedule;
}

/// @nodoc
class __$$PlantImplCopyWithImpl<$Res>
    extends _$PlantCopyWithImpl<$Res, _$PlantImpl>
    implements _$$PlantImplCopyWith<$Res> {
  __$$PlantImplCopyWithImpl(
      _$PlantImpl _value, $Res Function(_$PlantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? species = null,
    Object? location = null,
    Object? type = null,
    Object? dateAdded = null,
    Object? careSchedule = null,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? healthStatus = freezed,
    Object? lastWatered = freezed,
    Object? lastFertilized = freezed,
  }) {
    return _then(_$PlantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      species: null == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlantType,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      careSchedule: null == careSchedule
          ? _value.careSchedule
          : careSchedule // ignore: cast_nullable_to_non_nullable
              as CareSchedule,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      healthStatus: freezed == healthStatus
          ? _value.healthStatus
          : healthStatus // ignore: cast_nullable_to_non_nullable
              as HealthStatus?,
      lastWatered: freezed == lastWatered
          ? _value.lastWatered
          : lastWatered // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastFertilized: freezed == lastFertilized
          ? _value.lastFertilized
          : lastFertilized // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantImpl implements _Plant {
  const _$PlantImpl(
      {required this.id,
      required this.name,
      required this.species,
      required this.location,
      required this.type,
      required this.dateAdded,
      required this.careSchedule,
      this.imageUrl,
      this.notes,
      this.healthStatus,
      this.lastWatered,
      this.lastFertilized});

  factory _$PlantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String species;
  @override
  final String location;
  @override
  final PlantType type;
  @override
  final DateTime dateAdded;
  @override
  final CareSchedule careSchedule;
  @override
  final String? imageUrl;
  @override
  final String? notes;
  @override
  final HealthStatus? healthStatus;
  @override
  final DateTime? lastWatered;
  @override
  final DateTime? lastFertilized;

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, species: $species, location: $location, type: $type, dateAdded: $dateAdded, careSchedule: $careSchedule, imageUrl: $imageUrl, notes: $notes, healthStatus: $healthStatus, lastWatered: $lastWatered, lastFertilized: $lastFertilized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.species, species) || other.species == species) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.careSchedule, careSchedule) ||
                other.careSchedule == careSchedule) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.healthStatus, healthStatus) ||
                other.healthStatus == healthStatus) &&
            (identical(other.lastWatered, lastWatered) ||
                other.lastWatered == lastWatered) &&
            (identical(other.lastFertilized, lastFertilized) ||
                other.lastFertilized == lastFertilized));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      species,
      location,
      type,
      dateAdded,
      careSchedule,
      imageUrl,
      notes,
      healthStatus,
      lastWatered,
      lastFertilized);

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      __$$PlantImplCopyWithImpl<_$PlantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantImplToJson(
      this,
    );
  }
}

abstract class _Plant implements Plant {
  const factory _Plant(
      {required final String id,
      required final String name,
      required final String species,
      required final String location,
      required final PlantType type,
      required final DateTime dateAdded,
      required final CareSchedule careSchedule,
      final String? imageUrl,
      final String? notes,
      final HealthStatus? healthStatus,
      final DateTime? lastWatered,
      final DateTime? lastFertilized}) = _$PlantImpl;

  factory _Plant.fromJson(Map<String, dynamic> json) = _$PlantImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get species;
  @override
  String get location;
  @override
  PlantType get type;
  @override
  DateTime get dateAdded;
  @override
  CareSchedule get careSchedule;
  @override
  String? get imageUrl;
  @override
  String? get notes;
  @override
  HealthStatus? get healthStatus;
  @override
  DateTime? get lastWatered;
  @override
  DateTime? get lastFertilized;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CareSchedule _$CareScheduleFromJson(Map<String, dynamic> json) {
  return _CareSchedule.fromJson(json);
}

/// @nodoc
mixin _$CareSchedule {
  int get wateringIntervalDays => throw _privateConstructorUsedError;
  int get fertilizingIntervalDays => throw _privateConstructorUsedError;
  int? get repottingIntervalMonths => throw _privateConstructorUsedError;
  List<String>? get careNotes => throw _privateConstructorUsedError;

  /// Serializes this CareSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CareSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CareScheduleCopyWith<CareSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CareScheduleCopyWith<$Res> {
  factory $CareScheduleCopyWith(
          CareSchedule value, $Res Function(CareSchedule) then) =
      _$CareScheduleCopyWithImpl<$Res, CareSchedule>;
  @useResult
  $Res call(
      {int wateringIntervalDays,
      int fertilizingIntervalDays,
      int? repottingIntervalMonths,
      List<String>? careNotes});
}

/// @nodoc
class _$CareScheduleCopyWithImpl<$Res, $Val extends CareSchedule>
    implements $CareScheduleCopyWith<$Res> {
  _$CareScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CareSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wateringIntervalDays = null,
    Object? fertilizingIntervalDays = null,
    Object? repottingIntervalMonths = freezed,
    Object? careNotes = freezed,
  }) {
    return _then(_value.copyWith(
      wateringIntervalDays: null == wateringIntervalDays
          ? _value.wateringIntervalDays
          : wateringIntervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      fertilizingIntervalDays: null == fertilizingIntervalDays
          ? _value.fertilizingIntervalDays
          : fertilizingIntervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      repottingIntervalMonths: freezed == repottingIntervalMonths
          ? _value.repottingIntervalMonths
          : repottingIntervalMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      careNotes: freezed == careNotes
          ? _value.careNotes
          : careNotes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CareScheduleImplCopyWith<$Res>
    implements $CareScheduleCopyWith<$Res> {
  factory _$$CareScheduleImplCopyWith(
          _$CareScheduleImpl value, $Res Function(_$CareScheduleImpl) then) =
      __$$CareScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int wateringIntervalDays,
      int fertilizingIntervalDays,
      int? repottingIntervalMonths,
      List<String>? careNotes});
}

/// @nodoc
class __$$CareScheduleImplCopyWithImpl<$Res>
    extends _$CareScheduleCopyWithImpl<$Res, _$CareScheduleImpl>
    implements _$$CareScheduleImplCopyWith<$Res> {
  __$$CareScheduleImplCopyWithImpl(
      _$CareScheduleImpl _value, $Res Function(_$CareScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of CareSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wateringIntervalDays = null,
    Object? fertilizingIntervalDays = null,
    Object? repottingIntervalMonths = freezed,
    Object? careNotes = freezed,
  }) {
    return _then(_$CareScheduleImpl(
      wateringIntervalDays: null == wateringIntervalDays
          ? _value.wateringIntervalDays
          : wateringIntervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      fertilizingIntervalDays: null == fertilizingIntervalDays
          ? _value.fertilizingIntervalDays
          : fertilizingIntervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      repottingIntervalMonths: freezed == repottingIntervalMonths
          ? _value.repottingIntervalMonths
          : repottingIntervalMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      careNotes: freezed == careNotes
          ? _value._careNotes
          : careNotes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CareScheduleImpl implements _CareSchedule {
  const _$CareScheduleImpl(
      {required this.wateringIntervalDays,
      required this.fertilizingIntervalDays,
      this.repottingIntervalMonths,
      final List<String>? careNotes})
      : _careNotes = careNotes;

  factory _$CareScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CareScheduleImplFromJson(json);

  @override
  final int wateringIntervalDays;
  @override
  final int fertilizingIntervalDays;
  @override
  final int? repottingIntervalMonths;
  final List<String>? _careNotes;
  @override
  List<String>? get careNotes {
    final value = _careNotes;
    if (value == null) return null;
    if (_careNotes is EqualUnmodifiableListView) return _careNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CareSchedule(wateringIntervalDays: $wateringIntervalDays, fertilizingIntervalDays: $fertilizingIntervalDays, repottingIntervalMonths: $repottingIntervalMonths, careNotes: $careNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CareScheduleImpl &&
            (identical(other.wateringIntervalDays, wateringIntervalDays) ||
                other.wateringIntervalDays == wateringIntervalDays) &&
            (identical(
                    other.fertilizingIntervalDays, fertilizingIntervalDays) ||
                other.fertilizingIntervalDays == fertilizingIntervalDays) &&
            (identical(
                    other.repottingIntervalMonths, repottingIntervalMonths) ||
                other.repottingIntervalMonths == repottingIntervalMonths) &&
            const DeepCollectionEquality()
                .equals(other._careNotes, _careNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      wateringIntervalDays,
      fertilizingIntervalDays,
      repottingIntervalMonths,
      const DeepCollectionEquality().hash(_careNotes));

  /// Create a copy of CareSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CareScheduleImplCopyWith<_$CareScheduleImpl> get copyWith =>
      __$$CareScheduleImplCopyWithImpl<_$CareScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CareScheduleImplToJson(
      this,
    );
  }
}

abstract class _CareSchedule implements CareSchedule {
  const factory _CareSchedule(
      {required final int wateringIntervalDays,
      required final int fertilizingIntervalDays,
      final int? repottingIntervalMonths,
      final List<String>? careNotes}) = _$CareScheduleImpl;

  factory _CareSchedule.fromJson(Map<String, dynamic> json) =
      _$CareScheduleImpl.fromJson;

  @override
  int get wateringIntervalDays;
  @override
  int get fertilizingIntervalDays;
  @override
  int? get repottingIntervalMonths;
  @override
  List<String>? get careNotes;

  /// Create a copy of CareSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CareScheduleImplCopyWith<_$CareScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

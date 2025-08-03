// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'land_size.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LandSize _$LandSizeFromJson(Map<String, dynamic> json) {
  return _LandSize.fromJson(json);
}

/// @nodoc
mixin _$LandSize {
  double get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// Serializes this LandSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LandSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LandSizeCopyWith<LandSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LandSizeCopyWith<$Res> {
  factory $LandSizeCopyWith(LandSize value, $Res Function(LandSize) then) =
      _$LandSizeCopyWithImpl<$Res, LandSize>;
  @useResult
  $Res call({double value, String unit});
}

/// @nodoc
class _$LandSizeCopyWithImpl<$Res, $Val extends LandSize>
    implements $LandSizeCopyWith<$Res> {
  _$LandSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LandSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LandSizeImplCopyWith<$Res>
    implements $LandSizeCopyWith<$Res> {
  factory _$$LandSizeImplCopyWith(
          _$LandSizeImpl value, $Res Function(_$LandSizeImpl) then) =
      __$$LandSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double value, String unit});
}

/// @nodoc
class __$$LandSizeImplCopyWithImpl<$Res>
    extends _$LandSizeCopyWithImpl<$Res, _$LandSizeImpl>
    implements _$$LandSizeImplCopyWith<$Res> {
  __$$LandSizeImplCopyWithImpl(
      _$LandSizeImpl _value, $Res Function(_$LandSizeImpl) _then)
      : super(_value, _then);

  /// Create a copy of LandSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(_$LandSizeImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LandSizeImpl implements _LandSize {
  const _$LandSizeImpl({required this.value, required this.unit});

  factory _$LandSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LandSizeImplFromJson(json);

  @override
  final double value;
  @override
  final String unit;

  @override
  String toString() {
    return 'LandSize(value: $value, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LandSizeImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, unit);

  /// Create a copy of LandSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LandSizeImplCopyWith<_$LandSizeImpl> get copyWith =>
      __$$LandSizeImplCopyWithImpl<_$LandSizeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LandSizeImplToJson(
      this,
    );
  }
}

abstract class _LandSize implements LandSize {
  const factory _LandSize(
      {required final double value,
      required final String unit}) = _$LandSizeImpl;

  factory _LandSize.fromJson(Map<String, dynamic> json) =
      _$LandSizeImpl.fromJson;

  @override
  double get value;
  @override
  String get unit;

  /// Create a copy of LandSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LandSizeImplCopyWith<_$LandSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Expert _$ExpertFromJson(Map<String, dynamic> json) {
  return _Expert.fromJson(json);
}

/// @nodoc
mixin _$Expert {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get credentials => throw _privateConstructorUsedError;
  double get rating =>
      throw _privateConstructorUsedError; // Dummy rating for now
  int get followers =>
      throw _privateConstructorUsedError; // Dummy followers for now
  String? get avatar => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;

  /// Serializes this Expert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Expert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpertCopyWith<Expert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpertCopyWith<$Res> {
  factory $ExpertCopyWith(Expert value, $Res Function(Expert) then) =
      _$ExpertCopyWithImpl<$Res, Expert>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String email,
      String specialty,
      String bio,
      List<String> credentials,
      double rating,
      int followers,
      String? avatar,
      DateTime? approvedAt});
}

/// @nodoc
class _$ExpertCopyWithImpl<$Res, $Val extends Expert>
    implements $ExpertCopyWith<$Res> {
  _$ExpertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? email = null,
    Object? specialty = null,
    Object? bio = null,
    Object? credentials = null,
    Object? rating = null,
    Object? followers = null,
    Object? avatar = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpertImplCopyWith<$Res> implements $ExpertCopyWith<$Res> {
  factory _$$ExpertImplCopyWith(
          _$ExpertImpl value, $Res Function(_$ExpertImpl) then) =
      __$$ExpertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String email,
      String specialty,
      String bio,
      List<String> credentials,
      double rating,
      int followers,
      String? avatar,
      DateTime? approvedAt});
}

/// @nodoc
class __$$ExpertImplCopyWithImpl<$Res>
    extends _$ExpertCopyWithImpl<$Res, _$ExpertImpl>
    implements _$$ExpertImplCopyWith<$Res> {
  __$$ExpertImplCopyWithImpl(
      _$ExpertImpl _value, $Res Function(_$ExpertImpl) _then)
      : super(_value, _then);

  /// Create a copy of Expert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? email = null,
    Object? specialty = null,
    Object? bio = null,
    Object? credentials = null,
    Object? rating = null,
    Object? followers = null,
    Object? avatar = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(_$ExpertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpertImpl implements _Expert {
  const _$ExpertImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.email,
      required this.specialty,
      required this.bio,
      final List<String> credentials = const [],
      this.rating = 4.0,
      this.followers = 0,
      this.avatar,
      this.approvedAt})
      : _credentials = credentials;

  factory _$ExpertImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpertImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String email;
  @override
  final String specialty;
  @override
  final String bio;
  final List<String> _credentials;
  @override
  @JsonKey()
  List<String> get credentials {
    if (_credentials is EqualUnmodifiableListView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_credentials);
  }

  @override
  @JsonKey()
  final double rating;
// Dummy rating for now
  @override
  @JsonKey()
  final int followers;
// Dummy followers for now
  @override
  final String? avatar;
  @override
  final DateTime? approvedAt;

  @override
  String toString() {
    return 'Expert(id: $id, userId: $userId, name: $name, email: $email, specialty: $specialty, bio: $bio, credentials: $credentials, rating: $rating, followers: $followers, avatar: $avatar, approvedAt: $approvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      email,
      specialty,
      bio,
      const DeepCollectionEquality().hash(_credentials),
      rating,
      followers,
      avatar,
      approvedAt);

  /// Create a copy of Expert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpertImplCopyWith<_$ExpertImpl> get copyWith =>
      __$$ExpertImplCopyWithImpl<_$ExpertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpertImplToJson(
      this,
    );
  }
}

abstract class _Expert implements Expert {
  const factory _Expert(
      {required final String id,
      required final String userId,
      required final String name,
      required final String email,
      required final String specialty,
      required final String bio,
      final List<String> credentials,
      final double rating,
      final int followers,
      final String? avatar,
      final DateTime? approvedAt}) = _$ExpertImpl;

  factory _Expert.fromJson(Map<String, dynamic> json) = _$ExpertImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get email;
  @override
  String get specialty;
  @override
  String get bio;
  @override
  List<String> get credentials;
  @override
  double get rating; // Dummy rating for now
  @override
  int get followers; // Dummy followers for now
  @override
  String? get avatar;
  @override
  DateTime? get approvedAt;

  /// Create a copy of Expert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpertImplCopyWith<_$ExpertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

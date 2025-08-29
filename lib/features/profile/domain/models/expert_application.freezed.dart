// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expert_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpertApplication _$ExpertApplicationFromJson(Map<String, dynamic> json) {
  return _ExpertApplication.fromJson(json);
}

/// @nodoc
mixin _$ExpertApplication {
  String? get id => throw _privateConstructorUsedError; // Firestore document ID
  String get userId => throw _privateConstructorUsedError;
  String get userEmail => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  String get experience => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get credentials => throw _privateConstructorUsedError;
  ExpertApplicationStatus get status => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewNotes => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;

  /// Serializes this ExpertApplication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpertApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpertApplicationCopyWith<ExpertApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpertApplicationCopyWith<$Res> {
  factory $ExpertApplicationCopyWith(
          ExpertApplication value, $Res Function(ExpertApplication) then) =
      _$ExpertApplicationCopyWithImpl<$Res, ExpertApplication>;
  @useResult
  $Res call(
      {String? id,
      String userId,
      String userEmail,
      String userName,
      String specialty,
      String experience,
      String bio,
      List<String> credentials,
      ExpertApplicationStatus status,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewNotes,
      String? reviewedBy});
}

/// @nodoc
class _$ExpertApplicationCopyWithImpl<$Res, $Val extends ExpertApplication>
    implements $ExpertApplicationCopyWith<$Res> {
  _$ExpertApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpertApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? userEmail = null,
    Object? userName = null,
    Object? specialty = null,
    Object? experience = null,
    Object? bio = null,
    Object? credentials = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewNotes = freezed,
    Object? reviewedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExpertApplicationStatus,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewNotes: freezed == reviewNotes
          ? _value.reviewNotes
          : reviewNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpertApplicationImplCopyWith<$Res>
    implements $ExpertApplicationCopyWith<$Res> {
  factory _$$ExpertApplicationImplCopyWith(_$ExpertApplicationImpl value,
          $Res Function(_$ExpertApplicationImpl) then) =
      __$$ExpertApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String userId,
      String userEmail,
      String userName,
      String specialty,
      String experience,
      String bio,
      List<String> credentials,
      ExpertApplicationStatus status,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewNotes,
      String? reviewedBy});
}

/// @nodoc
class __$$ExpertApplicationImplCopyWithImpl<$Res>
    extends _$ExpertApplicationCopyWithImpl<$Res, _$ExpertApplicationImpl>
    implements _$$ExpertApplicationImplCopyWith<$Res> {
  __$$ExpertApplicationImplCopyWithImpl(_$ExpertApplicationImpl _value,
      $Res Function(_$ExpertApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExpertApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? userEmail = null,
    Object? userName = null,
    Object? specialty = null,
    Object? experience = null,
    Object? bio = null,
    Object? credentials = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewNotes = freezed,
    Object? reviewedBy = freezed,
  }) {
    return _then(_$ExpertApplicationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExpertApplicationStatus,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewNotes: freezed == reviewNotes
          ? _value.reviewNotes
          : reviewNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpertApplicationImpl implements _ExpertApplication {
  const _$ExpertApplicationImpl(
      {this.id,
      required this.userId,
      required this.userEmail,
      required this.userName,
      required this.specialty,
      required this.experience,
      required this.bio,
      final List<String> credentials = const [],
      this.status = ExpertApplicationStatus.pending,
      this.submittedAt,
      this.reviewedAt,
      this.reviewNotes,
      this.reviewedBy})
      : _credentials = credentials;

  factory _$ExpertApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpertApplicationImplFromJson(json);

  @override
  final String? id;
// Firestore document ID
  @override
  final String userId;
  @override
  final String userEmail;
  @override
  final String userName;
  @override
  final String specialty;
  @override
  final String experience;
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
  final ExpertApplicationStatus status;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final String? reviewNotes;
  @override
  final String? reviewedBy;

  @override
  String toString() {
    return 'ExpertApplication(id: $id, userId: $userId, userEmail: $userEmail, userName: $userName, specialty: $specialty, experience: $experience, bio: $bio, credentials: $credentials, status: $status, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewNotes: $reviewNotes, reviewedBy: $reviewedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpertApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewNotes, reviewNotes) ||
                other.reviewNotes == reviewNotes) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      userEmail,
      userName,
      specialty,
      experience,
      bio,
      const DeepCollectionEquality().hash(_credentials),
      status,
      submittedAt,
      reviewedAt,
      reviewNotes,
      reviewedBy);

  /// Create a copy of ExpertApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpertApplicationImplCopyWith<_$ExpertApplicationImpl> get copyWith =>
      __$$ExpertApplicationImplCopyWithImpl<_$ExpertApplicationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpertApplicationImplToJson(
      this,
    );
  }
}

abstract class _ExpertApplication implements ExpertApplication {
  const factory _ExpertApplication(
      {final String? id,
      required final String userId,
      required final String userEmail,
      required final String userName,
      required final String specialty,
      required final String experience,
      required final String bio,
      final List<String> credentials,
      final ExpertApplicationStatus status,
      final DateTime? submittedAt,
      final DateTime? reviewedAt,
      final String? reviewNotes,
      final String? reviewedBy}) = _$ExpertApplicationImpl;

  factory _ExpertApplication.fromJson(Map<String, dynamic> json) =
      _$ExpertApplicationImpl.fromJson;

  @override
  String? get id; // Firestore document ID
  @override
  String get userId;
  @override
  String get userEmail;
  @override
  String get userName;
  @override
  String get specialty;
  @override
  String get experience;
  @override
  String get bio;
  @override
  List<String> get credentials;
  @override
  ExpertApplicationStatus get status;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get reviewedAt;
  @override
  String? get reviewNotes;
  @override
  String? get reviewedBy;

  /// Create a copy of ExpertApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpertApplicationImplCopyWith<_$ExpertApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

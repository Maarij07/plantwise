// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expert_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpertApplicationImpl _$$ExpertApplicationImplFromJson(
        Map<String, dynamic> json) =>
    _$ExpertApplicationImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      userName: json['userName'] as String,
      specialty: json['specialty'] as String,
      experience: json['experience'] as String,
      bio: json['bio'] as String,
      credentials: (json['credentials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: $enumDecodeNullable(
              _$ExpertApplicationStatusEnumMap, json['status']) ??
          ExpertApplicationStatus.pending,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewNotes: json['reviewNotes'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
    );

Map<String, dynamic> _$$ExpertApplicationImplToJson(
        _$ExpertApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userEmail': instance.userEmail,
      'userName': instance.userName,
      'specialty': instance.specialty,
      'experience': instance.experience,
      'bio': instance.bio,
      'credentials': instance.credentials,
      'status': _$ExpertApplicationStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewNotes': instance.reviewNotes,
      'reviewedBy': instance.reviewedBy,
    };

const _$ExpertApplicationStatusEnumMap = {
  ExpertApplicationStatus.pending: 'pending',
  ExpertApplicationStatus.approved: 'approved',
  ExpertApplicationStatus.rejected: 'rejected',
  ExpertApplicationStatus.underReview: 'under_review',
};

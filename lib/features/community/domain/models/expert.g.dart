// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpertImpl _$$ExpertImplFromJson(Map<String, dynamic> json) => _$ExpertImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      specialty: json['specialty'] as String,
      bio: json['bio'] as String,
      credentials: (json['credentials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      avatar: json['avatar'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$$ExpertImplToJson(_$ExpertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'specialty': instance.specialty,
      'bio': instance.bio,
      'credentials': instance.credentials,
      'rating': instance.rating,
      'followers': instance.followers,
      'avatar': instance.avatar,
      'approvedAt': instance.approvedAt?.toIso8601String(),
    };

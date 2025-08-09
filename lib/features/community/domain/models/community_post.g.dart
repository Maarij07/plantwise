// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityPostImpl _$$CommunityPostImplFromJson(Map<String, dynamic> json) =>
    _$CommunityPostImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likedBy:
          (json['likedBy'] as List<dynamic>).map((e) => e as String).toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      location: json['location'] as String?,
      postType: $enumDecodeNullable(_$PostTypeEnumMap, json['postType']),
    );

Map<String, dynamic> _$$CommunityPostImplToJson(_$CommunityPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'likedBy': instance.likedBy,
      'comments': instance.comments,
      'tags': instance.tags,
      'location': instance.location,
      'postType': _$PostTypeEnumMap[instance.postType],
    };

const _$PostTypeEnumMap = {
  PostType.general: 'general',
  PostType.question: 'question',
  PostType.tip: 'tip',
  PostType.showcase: 'showcase',
  PostType.help: 'help',
};

_$CommunityCommentImpl _$$CommunityCommentImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityCommentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likedBy:
          (json['likedBy'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$CommunityCommentImplToJson(
        _$CommunityCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'likedBy': instance.likedBy,
    };

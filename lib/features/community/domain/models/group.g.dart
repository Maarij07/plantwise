// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      adminId: json['adminId'] as String,
      adminName: json['adminName'] as String,
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: $enumDecode(_$GroupCategoryEnumMap, json['category']),
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'adminId': instance.adminId,
      'adminName': instance.adminName,
      'memberIds': instance.memberIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'category': _$GroupCategoryEnumMap[instance.category]!,
      'imageUrl': instance.imageUrl,
      'isPublic': instance.isPublic,
      'tags': instance.tags,
    };

const _$GroupCategoryEnumMap = {
  GroupCategory.general: 'general',
  GroupCategory.plantCare: 'plantCare',
  GroupCategory.gardening: 'gardening',
  GroupCategory.houseplants: 'houseplants',
  GroupCategory.succulents: 'succulents',
  GroupCategory.vegetables: 'vegetables',
  GroupCategory.flowers: 'flowers',
  GroupCategory.trees: 'trees',
  GroupCategory.herbs: 'herbs',
};

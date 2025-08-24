import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.adminName,
    required this.memberIds,
    required this.createdAt,
    required this.category,
    this.imageUrl,
    this.isPublic = true,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final String adminId;
  final String adminName;
  final List<String> memberIds;
  final DateTime createdAt;
  final GroupCategory category;
  final String? imageUrl;
  final bool isPublic;
  final List<String> tags;

  factory Group.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp conversion
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    // Handle GroupCategory enum
    GroupCategory category;
    if (json['category'] is String) {
      try {
        category = GroupCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => GroupCategory.general,
        );
      } catch (e) {
        category = GroupCategory.general;
      }
    } else {
      category = GroupCategory.general;
    }

    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      adminId: json['adminId'] ?? '',
      adminName: json['adminName'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: createdAt,
      category: category,
      imageUrl: json['imageUrl'],
      isPublic: json['isPublic'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'adminId': adminId,
      'adminName': adminName,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'tags': tags,
    };
  }
}

enum GroupCategory {
  general('General', Icons.group),
  plantCare('Plant Care', Icons.local_florist),
  gardening('Gardening', Icons.grass),
  houseplants('Houseplants', Icons.home),
  succulents('Succulents', Icons.eco),
  vegetables('Vegetables', Icons.agriculture),
  flowers('Flowers', Icons.local_florist),
  trees('Trees', Icons.park),
  herbs('Herbs', Icons.spa);

  const GroupCategory(this.displayName, this.icon);

  final String displayName;
  final IconData icon;
}

// Extension to add computed properties
extension GroupExtension on Group {
  int get memberCount => memberIds.length;
  
  bool isAdmin(String userId) => adminId == userId;
  bool isMember(String userId) => memberIds.contains(userId);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just created';
    }
  }
}

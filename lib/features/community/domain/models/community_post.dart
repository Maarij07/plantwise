import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'community_post.freezed.dart';

@freezed
class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
    String? imageUrl,
    required DateTime createdAt,
    required List<String> likedBy,
    required List<CommunityComment> comments,
    @Default([]) List<String> sharedBy,
    List<String>? tags,
    String? location,
    PostType? postType,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp conversion
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }
    
    // Handle comments with Timestamp conversion
    List<CommunityComment> comments = [];
    if (json['comments'] is List) {
      comments = (json['comments'] as List)
          .map((commentJson) => CommunityComment.fromJson(commentJson as Map<String, dynamic>))
          .toList();
    }
    
    // Handle PostType enum
    PostType? postType;
    if (json['postType'] is String) {
      try {
        postType = PostType.values.firstWhere(
          (e) => e.name == json['postType'],
          orElse: () => PostType.general,
        );
      } catch (e) {
        postType = PostType.general;
      }
    }
    
    return CommunityPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: createdAt,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      comments: comments,
      sharedBy: List<String>.from(json['sharedBy'] ?? []),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'],
      postType: postType,
    );
  }
}

@freezed
class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
    required DateTime createdAt,
    required List<String> likedBy,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp conversion
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }
    
    return CommunityComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      createdAt: createdAt,
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }
}

enum PostType {
  general('General'),
  question('Question'),
  tip('Tip'),
  showcase('Showcase'),
  help('Help Needed');

  const PostType(this.displayName);
  final String displayName;
}

// Extension to add computed properties
extension CommunityPostExtension on CommunityPost {
  int get likesCount => likedBy.length;
  int get commentsCount => comments.length;
  int get sharesCount => sharedBy.length;
  
  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isSharedBy(String userId) => sharedBy.contains(userId);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}

extension CommunityCommentExtension on CommunityComment {
  int get likesCount => likedBy.length;
  bool isLikedBy(String userId) => likedBy.contains(userId);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

extension PostTypeExtension on PostType {
  Color get color {
    switch (this) {
      case PostType.general:
        return const Color(0xFF6B7280); // Grey 500
      case PostType.question:
        return const Color(0xFF3B82F6); // Blue 500
      case PostType.tip:
        return const Color(0xFF10B981); // Emerald 500
      case PostType.showcase:
        return const Color(0xFF8B5CF6); // Violet 500
      case PostType.help:
        return const Color(0xFFF59E0B); // Amber 500
    }
  }

  IconData get icon {
    switch (this) {
      case PostType.general:
        return Icons.chat;
      case PostType.question:
        return Icons.help_outline;
      case PostType.tip:
        return Icons.lightbulb_outline;
      case PostType.showcase:
        return Icons.photo_camera;
      case PostType.help:
        return Icons.support_agent;
    }
  }
}

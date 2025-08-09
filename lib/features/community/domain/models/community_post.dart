import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

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
    List<String>? tags,
    String? location,
    PostType? postType,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);
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

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentFromJson(json);
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

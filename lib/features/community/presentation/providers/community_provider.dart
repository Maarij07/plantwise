import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/community_post.dart';
import '../../data/services/community_firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase service provider
final communityFirebaseServiceProvider = Provider<CommunityFirebaseService>((ref) {
  return CommunityFirebaseService();
});

// Current user provider - integrates with Firebase Auth
final currentUserProvider = Provider<CommunityUser?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return CommunityUser(
      id: user.uid,
      name: user.displayName ?? 'User',
      avatar: user.photoURL,
    );
  }
  return null;
});

// Community posts stream provider - real-time Firebase data
final communityPostsStreamProvider = StreamProvider<List<CommunityPost>>((ref) {
  final service = ref.watch(communityFirebaseServiceProvider);
  return service.getPostsStream();
});

// Community posts provider for backward compatibility and actions
final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>>((ref) {
  return CommunityPostsNotifier(ref);
});

class CommunityPostsNotifier extends StateNotifier<AsyncValue<List<CommunityPost>>> {
  final Ref _ref;
  late final CommunityFirebaseService _service;
  final ImagePicker _imagePicker = ImagePicker();

  CommunityPostsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _service = _ref.read(communityFirebaseServiceProvider);
    _watchPosts();
  }

  void _watchPosts() {
    _ref.listen<AsyncValue<List<CommunityPost>>>(communityPostsStreamProvider, (previous, next) {
      state = next;
    });
  }


  // Create a new post
  Future<String> createPost({
    required String content,
    File? image,
    String? location,
    PostType? postType,
    List<String>? tags,
  }) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final postId = await _service.createPost(
        userId: user.id,
        userName: user.name,
        userAvatar: user.avatar,
        content: content,
        imageFile: image,
        location: location,
        postType: postType,
        tags: tags,
      );

      return postId;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Add a comment to a post
  Future<void> addComment(String postId, String content) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _service.addComment(
        postId: postId,
        userId: user.id,
        userName: user.name,
        userAvatar: user.avatar,
        content: content,
      );
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Toggle like on a comment
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    try {
      await _service.toggleCommentLike(
        postId: postId,
        commentId: commentId,
        userId: userId,
      );
    } catch (e) {
      print('Error toggling comment like: $e');
      rethrow;
    }
  }

  // Share a post (external sharing and track it)
  Future<void> sharePost(CommunityPost post) async {
    final text = '${post.userName} shared: "${post.content}"\n\nShared via PlantWise';
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Track the share in Firebase
      await _service.toggleShare(post.id, user.id);
      
      // Share externally
      await Share.share(text);
    } catch (e) {
      print('Error sharing post: $e');
      rethrow;
    }
  }

  // Toggle share tracking only (without external sharing)
  Future<void> toggleShare(String postId, String userId) async {
    try {
      await _service.toggleShare(postId, userId);
    } catch (e) {
      print('Error toggling share: $e');
      rethrow;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _service.deletePost(postId, user.id);
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // Report a post
  Future<void> reportPost(String postId, String reason) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _service.reportPost(
        postId: postId,
        reporterId: user.id,
        reason: reason,
      );
    } catch (e) {
      print('Error reporting post: $e');
      rethrow;
    }
  }

  // Pick image for post
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }


}

// Helper class for user info
class CommunityUser {
  final String id;
  final String name;
  final String? avatar;

  const CommunityUser({
    required this.id,
    required this.name,
    this.avatar,
  });
}

// Provider to get posts that need attention (for notifications)
final postsNeedingAttentionProvider = Provider<List<CommunityPost>>((ref) {
  final postsAsync = ref.watch(communityPostsStreamProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  return postsAsync.when(
    data: (posts) {
      if (currentUser == null) return [];
      
      return posts.where((post) {
        // Posts where current user has been mentioned or replied to
        final hasNewComments = post.comments.any((comment) => 
            comment.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24))) &&
            comment.userId != currentUser.id);
        
        return hasNewComments && post.userId == currentUser.id;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

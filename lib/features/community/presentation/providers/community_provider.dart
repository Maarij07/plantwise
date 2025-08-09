import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/community_post.dart';

// Current user provider (simple implementation - in real app would come from auth)
final currentUserProvider = Provider<CommunityUser>((ref) {
  return const CommunityUser(
    id: 'current_user',
    name: 'You',
    avatar: null,
  );
});

// Community posts provider
final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, List<CommunityPost>>((ref) {
  return CommunityPostsNotifier();
});

class CommunityPostsNotifier extends StateNotifier<List<CommunityPost>> {
  CommunityPostsNotifier() : super([]) {
    _loadPosts();
  }

  static const String _postsKey = 'community_posts';
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList(_postsKey);
    
    if (postsJson != null && postsJson.isNotEmpty) {
      try {
        state = postsJson
            .map((json) => CommunityPost.fromJson(jsonDecode(json)))
            .toList();
      } catch (e) {
        // If there's an error parsing, initialize with sample data
        state = _getSamplePosts();
        await _savePosts();
      }
    } else {
      // Initialize with sample data
      state = _getSamplePosts();
      await _savePosts();
    }
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = state
        .map((post) => jsonEncode(post.toJson()))
        .toList();
    await prefs.setStringList(_postsKey, postsJson);
  }

  // Create a new post
  Future<void> createPost({
    required String content,
    File? image,
    String? location,
    PostType? postType,
    List<String>? tags,
  }) async {
    final newPost = CommunityPost(
      id: _generateId(),
      userId: 'current_user',
      userName: 'You',
      userAvatar: null,
      content: content,
      imageUrl: image?.path, // In real app, would upload to cloud storage
      createdAt: DateTime.now(),
      likedBy: [],
      comments: [],
      location: location,
      postType: postType ?? PostType.general,
      tags: tags,
    );

    state = [newPost, ...state];
    await _savePosts();
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    state = state.map((post) {
      if (post.id == postId) {
        final likedBy = List<String>.from(post.likedBy);
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        return post.copyWith(likedBy: likedBy);
      }
      return post;
    }).toList();
    await _savePosts();
  }

  // Add a comment to a post
  Future<void> addComment(String postId, String content, String userId, String userName) async {
    final comment = CommunityComment(
      id: _generateId(),
      userId: userId,
      userName: userName,
      userAvatar: null,
      content: content,
      createdAt: DateTime.now(),
      likedBy: [],
    );

    state = state.map((post) {
      if (post.id == postId) {
        final comments = List<CommunityComment>.from(post.comments);
        comments.add(comment);
        return post.copyWith(comments: comments);
      }
      return post;
    }).toList();
    await _savePosts();
  }

  // Toggle like on a comment
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    state = state.map((post) {
      if (post.id == postId) {
        final comments = post.comments.map((comment) {
          if (comment.id == commentId) {
            final likedBy = List<String>.from(comment.likedBy);
            if (likedBy.contains(userId)) {
              likedBy.remove(userId);
            } else {
              likedBy.add(userId);
            }
            return comment.copyWith(likedBy: likedBy);
          }
          return comment;
        }).toList();
        return post.copyWith(comments: comments);
      }
      return post;
    }).toList();
    await _savePosts();
  }

  // Share a post
  Future<void> sharePost(CommunityPost post) async {
    final text = '${post.userName} shared: "${post.content}"\n\nShared via PlantWise';
    try {
      if (post.imageUrl != null && File(post.imageUrl!).existsSync()) {
        await Share.shareXFiles(
          [XFile(post.imageUrl!)],
          text: text,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      // Fallback to copying to clipboard
      await Clipboard.setData(ClipboardData(text: text));
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  List<CommunityPost> _getSamplePosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Green',
        userAvatar: null,
        content: 'Just repotted my Monstera! The roots were completely root-bound. Any tips for helping it recover from transplant shock? I\'ve been keeping it in bright, indirect light and haven\'t watered yet.',
        imageUrl: null,
        createdAt: now.subtract(const Duration(hours: 2)),
        likedBy: ['user2', 'user3'],
        comments: [
          CommunityComment(
            id: 'c1',
            userId: 'user2',
            userName: 'Plant Dad Mike',
            userAvatar: null,
            content: 'Wait about a week before watering! The roots need time to heal.',
            createdAt: now.subtract(const Duration(hours: 1)),
            likedBy: ['user1'],
          ),
          CommunityComment(
            id: 'c2',
            userId: 'user3',
            userName: 'Green Thumb Gary',
            userAvatar: null,
            content: 'Also, make sure not to fertilize for at least a month after repotting.',
            createdAt: now.subtract(const Duration(minutes: 45)),
            likedBy: [],
          ),
        ],
        postType: PostType.question,
        tags: ['monstera', 'repotting', 'help'],
      ),
      CommunityPost(
        id: '2',
        userId: 'user2',
        userName: 'Plant Dad Mike',
        userAvatar: null,
        content: 'My fiddle leaf fig finally grew a new leaf! 🌱 Patience really pays off with these beauties. It took almost 3 months but it was worth the wait!',
        imageUrl: null,
        createdAt: now.subtract(const Duration(hours: 5)),
        likedBy: ['user1', 'user3', 'user4', 'user5'],
        comments: [
          CommunityComment(
            id: 'c3',
            userId: 'user1',
            userName: 'Sarah Green',
            userAvatar: null,
            content: 'Congratulations! That\'s so exciting 🎉',
            createdAt: now.subtract(const Duration(hours: 4)),
            likedBy: ['user2'],
          ),
        ],
        postType: PostType.showcase,
        tags: ['fiddle-leaf-fig', 'new-growth', 'patience'],
      ),
      CommunityPost(
        id: '3',
        userId: 'user3',
        userName: 'Indoor Jungle',
        userAvatar: null,
        content: 'Sunday plant care routine complete! ✅ Watered all the thirsty ones, misted the humidity lovers, and did a thorough pest check. How does everyone else organize their plant care schedule?',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 1)),
        likedBy: ['user1', 'user2', 'user4'],
        comments: [
          CommunityComment(
            id: 'c4',
            userId: 'user4',
            userName: 'Botanical Beth',
            userAvatar: null,
            content: 'I use a plant care app to track watering schedules!',
            createdAt: now.subtract(const Duration(hours: 20)),
            likedBy: ['user3'],
          ),
          CommunityComment(
            id: 'c5',
            userId: 'user1',
            userName: 'Sarah Green',
            userAvatar: null,
            content: 'I have a weekly checklist that I print out and check off',
            createdAt: now.subtract(const Duration(hours: 18)),
            likedBy: ['user3', 'user4'],
          ),
        ],
        postType: PostType.general,
        tags: ['plant-care', 'routine', 'sunday'],
      ),
      CommunityPost(
        id: '4',
        userId: 'user4',
        userName: 'Botanical Beth',
        userAvatar: null,
        content: '💡 Pro tip: If your plant leaves are turning yellow, don\'t panic! It could be natural aging, overwatering, or even underwatering. Check the soil moisture first and look at which leaves are affected.',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 2)),
        likedBy: ['user1', 'user2', 'user3', 'user5', 'user6'],
        comments: [
          CommunityComment(
            id: 'c6',
            userId: 'user5',
            userName: 'Newbie Gardener',
            userAvatar: null,
            content: 'This is so helpful! I always panic when I see yellow leaves',
            createdAt: now.subtract(const Duration(days: 1, hours: 20)),
            likedBy: ['user4'],
          ),
        ],
        postType: PostType.tip,
        tags: ['yellow-leaves', 'plant-care', 'troubleshooting'],
      ),
    ];
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
  final posts = ref.watch(communityPostsProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  return posts.where((post) {
    // Posts where current user has been mentioned or replied to
    final hasNewComments = post.comments.any((comment) => 
        comment.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24))) &&
        comment.userId != currentUser.id);
    
    return hasNewComments && post.userId == currentUser.id;
  }).toList();
});

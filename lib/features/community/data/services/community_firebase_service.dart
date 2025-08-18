import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../domain/models/community_post.dart';

class CommunityFirebaseService {
  static const String _postsCollection = 'community_posts';
  
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  CommunityFirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get real-time stream of community posts
  Stream<List<CommunityPost>> getPostsStream() {
    return _firestore
        .collection(_postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to prevent excessive data usage
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; // Ensure ID is included
              return CommunityPost.fromJson(data);
            } catch (e) {
              print('Error parsing post ${doc.id}: $e');
              return null;
            }
          })
          .where((post) => post != null)
          .cast<CommunityPost>()
          .toList();
    });
  }

  /// Create a new community post
  Future<String> createPost({
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
    File? imageFile,
    String? location,
    PostType? postType,
    List<String>? tags,
  }) async {
    try {
      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, userId);
      }

      // Create post data
      final postData = {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likedBy': <String>[],
        'comments': <Map<String, dynamic>>[],
        'sharedBy': <String>[],
        'location': location,
        'postType': postType?.name,
        'tags': tags ?? <String>[],
      };

      // Add to Firestore
      final docRef = await _firestore
          .collection(_postsCollection)
          .add(postData);
      
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = 'posts/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final docRef = _firestore.collection(_postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Post not found');
        }
        
        final data = snapshot.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        transaction.update(docRef, {'likedBy': likedBy});
      });
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Toggle share on a post (track who shared it)
  Future<void> toggleShare(String postId, String userId) async {
    try {
      final docRef = _firestore.collection(_postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Post not found');
        }
        
        final data = snapshot.data()!;
        final sharedBy = List<String>.from(data['sharedBy'] ?? []);
        
        if (sharedBy.contains(userId)) {
          sharedBy.remove(userId);
        } else {
          sharedBy.add(userId);
        }
        
        transaction.update(docRef, {'sharedBy': sharedBy});
      });
    } catch (e) {
      print('Error toggling share: $e');
      throw Exception('Failed to toggle share: $e');
    }
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
  }) async {
    try {
      final comment = {
        'id': _generateCommentId(),
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'createdAt': Timestamp.now(),
        'likedBy': <String>[],
      };

      await _firestore.collection(_postsCollection).doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Toggle like on a comment
  Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection(_postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Post not found');
        }
        
        final data = snapshot.data()!;
        final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        
        final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
        if (commentIndex == -1) {
          throw Exception('Comment not found');
        }
        
        final comment = comments[commentIndex];
        final likedBy = List<String>.from(comment['likedBy'] ?? []);
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        
        comments[commentIndex] = {
          ...comment,
          'likedBy': likedBy,
        };
        
        transaction.update(docRef, {'comments': comments});
      });
    } catch (e) {
      print('Error toggling comment like: $e');
      throw Exception('Failed to toggle comment like: $e');
    }
  }

  /// Delete a post (only by post owner)
  Future<void> deletePost(String postId, String userId) async {
    try {
      final docRef = _firestore.collection(_postsCollection).doc(postId);
      final snapshot = await docRef.get();
      
      if (!snapshot.exists) {
        throw Exception('Post not found');
      }
      
      final data = snapshot.data()!;
      if (data['userId'] != userId) {
        throw Exception('Unauthorized: You can only delete your own posts');
      }
      
      // Delete associated image if exists
      if (data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          print('Error deleting image: $e');
          // Continue with post deletion even if image deletion fails
        }
      }
      
      // Delete the post
      await docRef.delete();
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Get posts by a specific user
  Stream<List<CommunityPost>> getUserPostsStream(String userId) {
    return _firestore
        .collection(_postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return CommunityPost.fromJson(data);
            } catch (e) {
              print('Error parsing user post ${doc.id}: $e');
              return null;
            }
          })
          .where((post) => post != null)
          .cast<CommunityPost>()
          .toList();
    });
  }

  /// Search posts by content or tags
  Future<List<CommunityPost>> searchPosts(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // In a production app, you'd use Algolia, Elasticsearch, or similar
      
      // Search by tags (exact match)
      final tagQuery = await _firestore
          .collection(_postsCollection)
          .where('tags', arrayContains: query.toLowerCase())
          .limit(20)
          .get();
      
      final posts = tagQuery.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return CommunityPost.fromJson(data);
            } catch (e) {
              print('Error parsing search result ${doc.id}: $e');
              return null;
            }
          })
          .where((post) => post != null)
          .cast<CommunityPost>()
          .toList();
      
      // Sort by creation date
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return posts;
    } catch (e) {
      print('Error searching posts: $e');
      throw Exception('Failed to search posts: $e');
    }
  }

  /// Report a post
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('post_reports').add({
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewed, resolved
      });
    } catch (e) {
      print('Error reporting post: $e');
      throw Exception('Failed to report post: $e');
    }
  }

  /// Generate a unique comment ID
  String _generateCommentId() {
    return 'comment_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Get post statistics (for admin panel)
  Future<Map<String, int>> getPostStatistics() async {
    try {
      final snapshot = await _firestore.collection(_postsCollection).get();
      
      int totalPosts = snapshot.docs.length;
      int totalComments = 0;
      int totalLikes = 0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final comments = data['comments'] as List<dynamic>? ?? [];
        final likes = data['likedBy'] as List<dynamic>? ?? [];
        
        totalComments += comments.length;
        totalLikes += likes.length;
      }
      
      return {
        'totalPosts': totalPosts,
        'totalComments': totalComments,
        'totalLikes': totalLikes,
      };
    } catch (e) {
      print('Error getting post statistics: $e');
      return {
        'totalPosts': 0,
        'totalComments': 0,
        'totalLikes': 0,
      };
    }
  }

  /// Clean up old posts (for maintenance)
  Future<void> cleanupOldPosts({int daysOld = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      final oldPosts = await _firestore
          .collection(_postsCollection)
          .where('createdAt', isLessThan: cutoffTimestamp)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in oldPosts.docs) {
        // Delete associated images
        final data = doc.data();
        if (data['imageUrl'] != null) {
          try {
            await _storage.refFromURL(data['imageUrl']).delete();
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }
        
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cleaned up ${oldPosts.docs.length} old posts');
    } catch (e) {
      print('Error cleaning up old posts: $e');
    }
  }
}

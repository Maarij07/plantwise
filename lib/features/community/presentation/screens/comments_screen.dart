import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final CommunityPost post;

  const CommentsScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current auth state
    final authState = ref.watch(authStateProvider);
    
    // Use stream provider for real-time post updates, but show UI immediately
    final postsAsync = ref.watch(communityPostsStreamProvider);
    
    // Find the most up-to-date post or fallback to the original
    final currentPost = postsAsync.maybeWhen(
      data: (posts) {
        try {
          return posts.firstWhere((p) => p.id == widget.post.id);
        } catch (e) {
          return widget.post; // Fallback to original post
        }
      },
      orElse: () => widget.post, // Use original post while loading/error
    );
    
    // Get current user from AuthState
    final currentUser = authState.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
    
    // Build UI immediately with available data
    return _buildCommentsUI(context, currentPost, currentUser);
  }
  
  Widget _buildCommentsUI(BuildContext context, CommunityPost updatedPost, authUser) {
    // Check if we're still loading updates from the stream
    final postsAsync = ref.watch(communityPostsStreamProvider);
    final isLoadingUpdates = postsAsync.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (isLoadingUpdates)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: true, // This is crucial for proper keyboard handling
      body: Column(
        children: [
          // Post summary
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : AppColors.grey50,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.grey700 : AppColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: updatedPost.userAvatar != null
                      ? NetworkImage(updatedPost.userAvatar!)
                      : null,
                  child: updatedPost.userAvatar == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        updatedPost.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.surface : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        updatedPost.content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.grey200 : AppColors.grey700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Comments list
          Expanded(
            child: updatedPost.comments.isEmpty
                ? _buildEmptyCommentsState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: updatedPost.comments.length,
                    itemBuilder: (context, index) {
                      final comment = updatedPost.comments[index];
                      return _CommentItem(
                        comment: comment,
                        postId: updatedPost.id,
                        currentUserId: authUser?.id ?? '',
                      );
                    },
                  ),
          ),
          
          // Comment input - Now properly positioned
          SafeArea(
            child: _buildCommentInput(authUser),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.grey200 
                    : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.grey400 
                    : AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(authUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey700 : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: authUser?.photoUrl != null
                ? NetworkImage(authUser!.photoUrl!)
                : null,
            child: authUser?.photoUrl == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: isDark ? AppColors.surface : AppColors.grey900,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.grey600 : AppColors.grey300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.grey600 : AppColors.grey300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2D2D2D) : AppColors.grey50,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => authUser != null ? _postComment(authUser) : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isPosting
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _commentController.text.trim().isEmpty || authUser == null
                      ? null
                      : () => _postComment(authUser),
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                  disabledColor: AppColors.grey400,
                ),
        ],
      ),
    );
  }

  Future<void> _postComment(authUser) async {
    if (_commentController.text.trim().isEmpty || _isPosting || authUser == null) return;

    final content = _commentController.text.trim();
    _commentController.clear();

    setState(() {
      _isPosting = true;
    });

    try {
      await ref.read(communityPostsProvider.notifier).addComment(
        widget.post.id,
        content,
      );

      // Scroll to bottom to show the new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }
}

class _CommentItem extends ConsumerWidget {
  final CommunityComment comment;
  final String postId;
  final String currentUserId;

  const _CommentItem({
    required this.comment,
    required this.postId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = comment.isLikedBy(currentUserId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: comment.userAvatar != null
                ? NetworkImage(comment.userAvatar!)
                : null,
            child: comment.userAvatar == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.surface : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.grey200 : AppColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        ref.read(communityPostsProvider.notifier).toggleCommentLike(
                          postId,
                          comment.id,
                          currentUserId,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isLiked ? Colors.red : AppColors.grey600,
                            ),
                            if (comment.likesCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                comment.likesCount.toString(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isLiked ? Colors.red : (isDark ? AppColors.grey400 : AppColors.grey600),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

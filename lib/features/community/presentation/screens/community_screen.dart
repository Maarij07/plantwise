import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';
import 'comments_screen.dart';
import 'create_post_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey600,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
            Tab(text: 'Experts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FeedTab(),
          _GroupsTab(),
          _ExpertsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPost(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality coming soon!')),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications coming soon!')),
    );
  }

  void _createPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(communityPostsProvider);
    
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16),
              Text(
                'No posts yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to share something with the community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // In a real app, this would fetch new posts from the server
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: posts.length,
        itemBuilder: (context, index) => _PostCard(post: posts[index]),
      ),
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Groups
          Text(
            'Recommended Groups',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sampleGroups.length,
              itemBuilder: (context, index) =>
                  _GroupCard(group: _sampleGroups[index]),
            ),
          ),
          const SizedBox(height: 32),
          // My Groups
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Groups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: _sampleGroups
                .take(3)
                .map((group) => _GroupListTile(group: group))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _sampleExperts.length,
      itemBuilder: (context, index) => _ExpertCard(expert: _sampleExperts[index]),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey800,
                            ),
                          ),
                          if (post.postType != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: post.postType!.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: post.postType!.color.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    post.postType!.icon,
                                    size: 10,
                                    color: post.postType!.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.postType!.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: post.postType!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (post.location != null) ...[
                            const SizedBox(width: 4),
                            Text('•', style: TextStyle(color: AppColors.grey400)),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              post.location!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey500,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  color: AppColors.grey500,
                  onPressed: () => _showPostOptions(context, post, ref),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: AppColors.grey800,
              ),
            ),
          ),
          
          // Tags
          if (post.tags != null && post.tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.tags!.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // Image
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            _buildPostImage(post.imageUrl!),
          ],
          
          const SizedBox(height: 12),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ModernActionButton(
                  icon: post.isLikedBy(currentUser.id) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  label: post.likesCount.toString(),
                  color: post.isLikedBy(currentUser.id) 
                      ? Colors.red 
                      : AppColors.grey600,
                  isActive: post.isLikedBy(currentUser.id),
                  onPressed: () => _toggleLike(post, currentUser.id, ref),
                ),
                const SizedBox(width: 20),
                _ModernActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.commentsCount.toString(),
                  color: AppColors.grey600,
                  onPressed: () => _showComments(context, post, ref),
                ),
                const SizedBox(width: 20),
                _ModernActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: AppColors.grey600,
                  onPressed: () => _sharePost(context, post, ref),
                ),
              ],
            ),
          ),
          
          // Comments preview
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: AppColors.grey50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.comments.length > 1)
                    GestureDetector(
                      onTap: () => _showComments(context, post, ref),
                      child: Text(
                        'View all ${post.commentsCount} comments',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (post.comments.length > 1) const SizedBox(height: 8),
                  _buildCommentPreview(post.comments.last),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      child: ClipRRect(
        child: _buildImageWidget(imageUrl),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else {
      // Local file path
      try {
        return Image.file(
          File(imageUrl),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      } catch (e) {
        return _buildImageError();
      }
    }
  }

  Widget _buildImageError() {
    return Container(
      height: 200,
      color: AppColors.grey100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 40, color: AppColors.grey400),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview(CommunityComment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: ' ${comment.content}',
                      style: const TextStyle(
                        color: AppColors.grey700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.timeAgo,
                style: const TextStyle(
                  color: AppColors.grey400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleLike(CommunityPost post, String userId, WidgetRef ref) async {
    await ref.read(communityPostsProvider.notifier).toggleLike(post.id, userId);
    
    // Show feedback with haptic feedback
    HapticFeedback.lightImpact();
  }

  void _sharePost(BuildContext context, CommunityPost post, WidgetRef ref) async {
    try {
      await ref.read(communityPostsProvider.notifier).sharePost(post);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post shared successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPostOptions(BuildContext context, CommunityPost post, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PostOptionsSheet(post: post),
    );
  }

  void _showComments(BuildContext context, CommunityPost post, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(post: post),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final CommunityGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: group.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(
                group.icon,
                size: 40,
                color: group.color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.members} members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        side: BorderSide(color: group.color),
                      ),
                      child: Text(
                        'Join',
                        style: TextStyle(color: group.color, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupListTile extends StatelessWidget {
  final CommunityGroup group;

  const _GroupListTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: group.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(group.icon, color: group.color),
        ),
        title: Text(group.name),
        subtitle: Text('${group.members} members'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final PlantExpert expert;

  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: expert.avatar != null
                  ? NetworkImage(expert.avatar!)
                  : null,
              child: expert.avatar == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expert.specialty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expert.rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${expert.followers} followers',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  child: const Text('Follow'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
        top: AppConstants.paddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              Text(
                'Create Post',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _controller.text.isNotEmpty ? () => _sharePost() : null,
                child: const Text('Share'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Share your plant journey, ask questions, or give advice...',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera),
                color: AppColors.primary,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.image),
                color: AppColors.primary,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sharePost() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post shared successfully!')),
    );
  }
}

// Local models for UI components

class CommunityGroup {
  final String id;
  final String name;
  final int members;
  final IconData icon;
  final Color color;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.icon,
    required this.color,
  });
}

class PlantExpert {
  final String id;
  final String name;
  final String specialty;
  final String? avatar;
  final double rating;
  final int followers;

  PlantExpert({
    required this.id,
    required this.name,
    required this.specialty,
    this.avatar,
    required this.rating,
    required this.followers,
  });
}

// Sample data

final List<CommunityGroup> _sampleGroups = [
  CommunityGroup(
    id: '1',
    name: 'Monstera Lovers',
    members: 12400,
    icon: Icons.eco,
    color: AppColors.primary,
  ),
  CommunityGroup(
    id: '2',
    name: 'Succulent Society',
    members: 8200,
    icon: Icons.grass,
    color: AppColors.secondary,
  ),
  CommunityGroup(
    id: '3',
    name: 'Plant Propagation',
    members: 15600,
    icon: Icons.spa,
    color: Colors.purple,
  ),
  CommunityGroup(
    id: '4',
    name: 'Houseplant Help',
    members: 23100,
    icon: Icons.help_outline,
    color: Colors.orange,
  ),
];

final List<PlantExpert> _sampleExperts = [
  PlantExpert(
    id: '1',
    name: 'Dr. Emily Plant',
    specialty: 'Indoor Plant Care',
    rating: 4.9,
    followers: 15200,
  ),
  PlantExpert(
    id: '2',
    name: 'Green Thumb Gary',
    specialty: 'Succulent Expert',
    rating: 4.7,
    followers: 8900,
  ),
  PlantExpert(
    id: '3',
    name: 'Botanical Beth',
    specialty: 'Plant Diseases',
    rating: 4.8,
    followers: 12400,
  ),
];

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostOptionsSheet extends StatelessWidget {
  final CommunityPost post;

  const _PostOptionsSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Post Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Options
          ListTile(
            leading: const Icon(Icons.bookmark_border, color: AppColors.primary),
            title: const Text('Save Post'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post saved!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: AppColors.primary),
            title: const Text('Copy Link'),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(
                text: 'https://plantwise.app/post/${post.id}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          if (post.userId == 'current_user') ...[
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit functionality coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Post'),
              textColor: AppColors.error,
              onTap: () => _showDeleteConfirmation(context),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.flag, color: AppColors.warning),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported. Thank you!'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text('Block User'),
              textColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${post.userName} has been blocked'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Navigator.pop(context); // Close options sheet first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon!'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

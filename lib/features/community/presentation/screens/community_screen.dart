import 'dart:io';
import 'package:flutter/material.dart';
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

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and time
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Post content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppColors.grey200,
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                _ActionButton(
                  icon: post.isLikedBy('current_user') ? Icons.favorite : Icons.favorite_border,
                  label: post.likesCount.toString(),
                  color: post.isLikedBy('current_user') ? Colors.red : AppColors.grey600,
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.commentsCount.toString(),
                  color: AppColors.grey600,
                  onPressed: () => _showComments(context, post),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: AppColors.grey600,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post options coming soon!')),
    );
  }

  void _showComments(BuildContext context, CommunityPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments coming soon!')),
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

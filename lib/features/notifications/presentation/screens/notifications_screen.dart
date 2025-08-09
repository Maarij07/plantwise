import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showNotificationSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => _markAllAsRead(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey600,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Plant Care'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PlantCareTab(),
          _CommunityTab(),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
    setState(() {
      // Update all notifications to read status
    });
  }
}

class _PlantCareTab extends StatelessWidget {
  const _PlantCareTab();

  @override
  Widget build(BuildContext context) {
    final careNotifications = _getSampleCareNotifications();
    
    if (careNotifications.isEmpty) {
      return _buildEmptyState(
        'No plant care notifications',
        'Your plants are all up to date!',
        Icons.eco,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: careNotifications.length,
      itemBuilder: (context, index) => _CareNotificationCard(
        notification: careNotifications[index],
      ),
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    final communityNotifications = _getSampleCommunityNotifications();
    
    if (communityNotifications.isEmpty) {
      return _buildEmptyState(
        'No community notifications',
        'Stay connected with fellow plant lovers!',
        Icons.people,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: communityNotifications.length,
      itemBuilder: (context, index) => _CommunityNotificationCard(
        notification: communityNotifications[index],
      ),
    );
  }
}

Widget _buildEmptyState(String title, String subtitle, IconData icon) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _CareNotificationCard extends StatelessWidget {
  final CareNotification notification;

  const _CareNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notification.priority.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            notification.type.icon,
            color: notification.priority.color,
          ),
        ),
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            if (notification.actionable)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                iconSize: 20,
                onPressed: () => _handleCareAction(context, notification),
              ),
          ],
        ),
        onTap: () => _showCareNotificationDetails(context, notification),
      ),
    );
  }

  void _handleCareAction(BuildContext context, CareNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${notification.plantName} as ${notification.type.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCareNotificationDetails(BuildContext context, CareNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            if (notification.careInstructions.isNotEmpty) ...[
              const Text(
                'Care Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...notification.careInstructions.map(
                (instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(instruction)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (notification.actionable)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleCareAction(context, notification);
              },
              child: Text('Mark as ${notification.type.actionText}'),
            ),
        ],
      ),
    );
  }
}

class _CommunityNotificationCard extends StatelessWidget {
  final CommunityNotification notification;

  const _CommunityNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.type.color.withOpacity(0.1),
          child: Icon(
            notification.type.icon,
            color: notification.type.color,
          ),
        ),
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _handleCommunityNotification(context, notification),
      ),
    );
  }

  void _handleCommunityNotification(BuildContext context, CommunityNotification notification) {
    // Navigate to relevant community section
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening community section...')),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _plantCareNotifications = true;
  bool _communityNotifications = true;
  bool _dailyReminders = true;
  bool _weeklyDigest = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          Text(
            'Plant Care Notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            title: 'Plant Care Reminders',
            subtitle: 'Get notified when your plants need care',
            value: _plantCareNotifications,
            onChanged: (value) => setState(() => _plantCareNotifications = value),
          ),
          _SettingsTile(
            title: 'Daily Reminders',
            subtitle: 'Check your plants daily',
            value: _dailyReminders,
            onChanged: (value) => setState(() => _dailyReminders = value),
          ),
          if (_dailyReminders) ...[
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Community Notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            title: 'Community Updates',
            subtitle: 'Get notified about community activities',
            value: _communityNotifications,
            onChanged: (value) => setState(() => _communityNotifications = value),
          ),
          _SettingsTile(
            title: 'Weekly Digest',
            subtitle: 'Weekly summary of community highlights',
            value: _weeklyDigest,
            onChanged: (value) => setState(() => _weeklyDigest = value),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

// Models
enum CareNotificationType {
  watering('watering', Icons.water_drop, 'watered'),
  fertilizing('fertilizing', Icons.grass, 'fertilized'),
  repotting('repotting', Icons.agriculture, 'repotted'),
  pruning('pruning', Icons.content_cut, 'pruned'),
  checkup('checkup', Icons.visibility, 'checked');

  const CareNotificationType(this.name, this.icon, this.actionText);
  final String name;
  final IconData icon;
  final String actionText;
}

enum NotificationPriority {
  low(AppColors.info),
  medium(AppColors.warning),
  high(AppColors.error);

  const NotificationPriority(this.color);
  final Color color;
}

enum CommunityNotificationType {
  like(Icons.favorite, Colors.red),
  comment(Icons.chat_bubble, AppColors.primary),
  follow(Icons.person_add, AppColors.secondary),
  mention(Icons.alternate_email, Colors.purple),
  post(Icons.article, AppColors.info);

  const CommunityNotificationType(this.icon, this.color);
  final IconData icon;
  final Color color;
}

class CareNotification {
  final String id;
  final String plantName;
  final CareNotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final bool actionable;
  final List<String> careInstructions;

  CareNotification({
    required this.id,
    required this.plantName,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.actionable = true,
    this.careInstructions = const [],
  });
}

class CommunityNotification {
  final String id;
  final CommunityNotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final String? userId;
  final String? postId;

  CommunityNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.userId,
    this.postId,
  });
}

// Sample data
List<CareNotification> _getSampleCareNotifications() {
  return [
    CareNotification(
      id: '1',
      plantName: 'Monstera Deliciosa',
      type: CareNotificationType.watering,
      priority: NotificationPriority.high,
      title: 'Watering Due',
      message: 'Your Monstera Deliciosa in the Living Room needs watering.',
      timeAgo: '2 hours ago',
      careInstructions: [
        'Check soil moisture by inserting finger 1-2 inches deep',
        'Water thoroughly until water drains from bottom',
        'Empty drainage tray after 30 minutes',
      ],
    ),
    CareNotification(
      id: '2',
      plantName: 'Snake Plant',
      type: CareNotificationType.fertilizing,
      priority: NotificationPriority.medium,
      title: 'Fertilizing Time',
      message: 'Your Snake Plant in the Bedroom is due for fertilizing.',
      timeAgo: '1 day ago',
      careInstructions: [
        'Use diluted liquid fertilizer (half strength)',
        'Apply during growing season (spring/summer)',
        'Water lightly after fertilizing',
      ],
    ),
    CareNotification(
      id: '3',
      plantName: 'Fiddle Leaf Fig',
      type: CareNotificationType.checkup,
      priority: NotificationPriority.low,
      title: 'Weekly Health Check',
      message: 'Time for your weekly plant health inspection.',
      timeAgo: '3 days ago',
      actionable: false,
      careInstructions: [
        'Check leaves for pests or diseases',
        'Remove any dead or yellowing leaves',
        'Dust leaves with damp cloth',
        'Rotate plant for even light exposure',
      ],
    ),
  ];
}

List<CommunityNotification> _getSampleCommunityNotifications() {
  return [
    CommunityNotification(
      id: '1',
      type: CommunityNotificationType.like,
      title: 'New Like on Your Post',
      message: 'Sarah Green liked your post about Monstera care.',
      timeAgo: '30 minutes ago',
    ),
    CommunityNotification(
      id: '2',
      type: CommunityNotificationType.comment,
      title: 'New Comment',
      message: 'Plant Dad Mike commented on your post: "Great advice!"',
      timeAgo: '2 hours ago',
    ),
    CommunityNotification(
      id: '3',
      type: CommunityNotificationType.follow,
      title: 'New Follower',
      message: 'Indoor Jungle started following you.',
      timeAgo: '1 day ago',
      isRead: true,
    ),
    CommunityNotification(
      id: '4',
      type: CommunityNotificationType.mention,
      title: 'You Were Mentioned',
      message: 'Dr. Emily Plant mentioned you in a post about plant diseases.',
      timeAgo: '2 days ago',
    ),
  ];
}

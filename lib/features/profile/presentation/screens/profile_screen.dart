import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/care_streak_providers.dart';
import '../../../plants/presentation/providers/plants_provider.dart';
import '../providers/land_size_provider.dart';
import '../widgets/land_size_setup_dialog.dart';
import '../widgets/bitmoji_avatar.dart';
import '../widgets/avatar_selector.dart';
import '../widgets/unified_avatar.dart';
import '../../data/services/avatar_service.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/avatar_provider.dart';
import '../providers/expert_application_provider.dart';
import '../../domain/models/expert_application.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  // State for current avatar seed
  String _currentAvatarSeed = 'default_seed';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to refresh profile data
  Future<void> _refreshProfile() async {
    print('Refreshing profile data...');
    try {
      // Invalidate the current user provider to force a refresh
      ref.invalidate(currentUserProvider);
      
      // Wait a bit for the provider to refresh
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('Profile data refreshed successfully');
    } catch (e) {
      print('Error refreshing profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final landSize = ref.watch(landSizeProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1024;
    
    // Extract user from AsyncValue - this will automatically update when user data changes
    final currentUser = currentUserAsync.when(
      data: (user) => user,
      loading: () => null,
      error: (error, stack) {
        print('Error loading current user: $error');
        return null;
      },
    );
    
    // Generate user-specific avatar seed
    if (currentUser != null && _currentAvatarSeed == 'default_seed') {
      _currentAvatarSeed = '${currentUser.email?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'user'}_${currentUser.name?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'avatar'}';
    }
    
    // Responsive padding based on screen size
    final horizontalPadding = isLargeScreen 
        ? 32.0 
        : isTablet 
            ? 24.0 
            : AppConstants.paddingMedium;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: isTablet ? 28 : 24,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Profile Header Section
                _buildSimpleProfileHeader(context, isTablet, currentUser),
                const SizedBox(height: 24),
            
            const SizedBox(height: 24),

            // Quick Stats Section - Real Data
            Consumer(
              builder: (context, ref, child) {
                final plantsAsync = ref.watch(plantsProvider);
                final plantsNeedingWaterAsync = ref.watch(plantsNeedingWaterProvider);
                final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
                
                return dashboardStatsAsync.when(
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.eco,
                                color: AppColors.success,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stats.totalPlants.toString(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'Plants',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: AppColors.warning,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stats.plantsNeedingWater.toString(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                              Text(
                                'Need Water',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stats.healthScorePercentage,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Health Score',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => Row(
                    children: [
                      Expanded(child: _buildStatCardSkeleton()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCardSkeleton()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCardSkeleton()),
                    ],
                  ),
                  error: (error, stack) => Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Personal Info Cards
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Update your name, & email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Garden Settings Section
            Text(
              'Garden Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Land Size Card
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.landscape_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Land Size'),
                subtitle: landSize != null 
                  ? Text('${landSize.value.toStringAsFixed(1)} ${landSize.unit}')
                  : const Text('Not set - Tap to configure'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLandSizeDialog(context, ref),
              ),
            ),

            const SizedBox(height: 24),

            // Premium Section
            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Premium Become Expert Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBecomeExpertWizard(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: isTablet ? 48 : 40,
                              height: isTablet ? 48 : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.school_outlined,
                                color: Colors.white,
                                size: isTablet ? 24 : 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Become an Expert',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: isTablet ? 18 : 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 10 : 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.7),
                              size: isTablet ? 20 : 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Share your knowledge and help the community grow',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 14 : 12,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.white.withOpacity(0.8),
                              size: isTablet ? 16 : 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Get verified expert badge',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: isTablet ? 12 : 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Settings Section
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // App Settings Cards
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage your notification preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showNotificationSettingsDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Theme'),
                    subtitle: const Text('Light, Dark, or System'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Account Settings Cards
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help with the app'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHelpDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Read our privacy policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPrivacyPolicyDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text('About App'),
                    subtitle: const Text('Version info and credits'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAboutAppDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.error,
                      ),
                    ),
                    title: const Text('Sign Out'),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ),

                const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build Simple Profile Header
  Widget _buildSimpleProfileHeader(BuildContext context, bool isTablet, dynamic currentUser) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showAvatarSelector(context),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 40 : 35,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: _buildDefaultAvatar(),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: isTablet ? 24 : 20,
                      height: isTablet ? 24 : 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: isTablet ? 12 : 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.name ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 24 : 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plant Enthusiast',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.eco,
                        size: isTablet ? 18 : 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final plantsAsync = ref.watch(plantsProvider);
                          
                          return plantsAsync.when(
                            data: (plants) => Text(
                              '${plants.length} Plants Growing',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                            loading: () => Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.grey300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            error: (error, stack) => Text(
                              'Loading plants...',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simplified avatar system using UnifiedAvatar
  Widget _buildDefaultAvatar() {
    return UnifiedAvatar(
      size: 80,
    );
  }

  // Enhanced Avatar for Hero Header
  Widget _buildEnhancedAvatar() {
    return GestureDetector(
      onTap: () => _showAvatarSelector(context),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.background,
                        child: _buildDefaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSelector(BuildContext context) {
    String? selectedSeed;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Your Avatar'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          child: AvatarPickerWidget(
            currentSeed: ref.watch(userAvatarProvider),
            gender: 'male', // Default gender - can be made dynamic later
            onAvatarSelected: (String newSeed) {
              selectedSeed = newSeed;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedSeed != null) {
                // Update the global avatar provider
                ref.read(userAvatarProvider.notifier).updateSeed(selectedSeed!);
              }
              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Avatar updated successfully!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLandSizeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const LandSizeSetupDialog(),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    context.push('/edit-profile');
  }

  void _showChangePasswordDialog(BuildContext context) {
    context.push('/change-password');
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Settings'),
        content: const Text('Set your location to receive personalized plant care tips and local weather information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open location settings
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Customize your notification preferences for plant care reminders, community updates, and more.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to notification settings
            },
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your preferred theme:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Theme'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Set light theme
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Theme'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Set dark theme
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('System Theme'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Set system theme
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }


  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help with PlantWise?'),
            const SizedBox(height: 16),
            const Text('• Check our FAQ section'),
            const Text('• Contact support team'),
            const Text('• Join our community forum'),
            const Text('• Watch tutorial videos'),
            const SizedBox(height: 16),
            const Text('Support Email: support@plantwise.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open help center
            },
            child: const Text('Get Help'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'PlantWise Privacy Policy\n\n'
            'Last updated: ${AppConstants.appVersion}\n\n'
            'We respect your privacy and are committed to protecting your personal data. '
            'This privacy policy will inform you about how we look after your personal data '
            'and tell you about your privacy rights.\n\n'
            'Information We Collect:\n'
            '• Account information (name, email)\n'
            '• Plant care data and preferences\n'
            '• Location data (with permission)\n'
            '• Usage analytics\n\n'
            'How We Use Your Information:\n'
            '• Provide personalized plant care\n'
            '• Send care reminders\n'
            '• Improve our services\n'
            '• Community features\n\n'
            'Your data is encrypted and secure.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open full privacy policy
            },
            child: const Text('Read Full Policy'),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About PlantWise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your personal plant care companion. Track your plants, get smart reminders, '
              'and connect with a community of plant lovers.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Built with ❤️ using Flutter',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Show app credits or changelog
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Call the actual sign out method
                await ref.read(authNotifierProvider.notifier).signOut();
                
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  context.go(AppConstants.signInRoute);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // Skeleton loading widget for stat cards
  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _showBecomeExpertWizard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BecomeExpertWizard(),
        fullscreenDialog: true,
      ),
    );
  }
}

// Become Expert Wizard Widget
class BecomeExpertWizard extends ConsumerStatefulWidget {
  const BecomeExpertWizard({Key? key}) : super(key: key);
  
  @override
  ConsumerState<BecomeExpertWizard> createState() => _BecomeExpertWizardState();
}

class _BecomeExpertWizardState extends ConsumerState<BecomeExpertWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data
  String _selectedSpecialty = '';
  String _experience = '';
  String _bio = '';
  List<String> _credentials = [];
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _credentialController = TextEditingController();

  final List<String> _specialties = [
    'Indoor Plant Care',
    'Outdoor Gardening',
    'Succulent & Cacti',
    'Plant Disease & Pests',
    'Plant Propagation',
    'Hydroponics',
    'Organic Gardening',
    'Tropical Plants',
    'Herbs & Vegetables',
    'Landscaping Design',
  ];

  final List<String> _experienceLevels = [
    '1-2 years',
    '3-5 years',
    '5-10 years',
    '10+ years',
    'Professional/Certified',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedSpecialty.isNotEmpty;
      case 1:
        return _experience.isNotEmpty;
      case 2:
        return _bioController.text.trim().isNotEmpty;
      case 3:
        return true; // Review step
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Become an Expert',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              children: [
                Row(
                  children: List.generate(
                    _totalSteps,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: index <= _currentStep
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.7),
                                  ],
                                )
                              : null,
                          color: index <= _currentStep
                              ? null
                              : AppColors.grey200,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          // Wizard Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSpecialtyStep(isTablet),
                _buildExperienceStep(isTablet),
                _buildBioStep(isTablet),
                _buildReviewStep(isTablet),
              ],
            ),
          ),
          // Bottom Navigation
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: _canProceed()
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _canProceed()
                          ? (_currentStep == _totalSteps - 1
                              ? _submitApplication
                              : _nextStep)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed()
                            ? Colors.transparent
                            : AppColors.grey300,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                      ),
                      child: Text(
                        _currentStep == _totalSteps - 1
                            ? 'Submit Application'
                            : 'Continue',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with premium styling
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFA500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: const Color(0xFFFFA500),
                    size: isTablet ? 32 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Specialty',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select the area where you have the most expertise',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Specialty options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTablet ? 2.5 : 2.2,
            ),
            itemCount: _specialties.length,
            itemBuilder: (context, index) {
              final specialty = _specialties[index];
              final isSelected = _selectedSpecialty == specialty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpecialty = specialty;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD700).withOpacity(0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : AppColors.grey200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getSpecialtyIcon(specialty),
                        color: isSelected
                            ? const Color(0xFFFFA500)
                            : AppColors.grey600,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        specialty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFFFA500)
                              : AppColors.grey700,
                          fontSize: isTablet ? 12 : 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFA500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: const Color(0xFFFFA500),
                    size: isTablet ? 32 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience Level',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How long have you been working with plants?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Experience options
          Column(
            children: _experienceLevels.map((level) {
              final isSelected = _experience == level;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _experience = level;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD700).withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFFFD700).withOpacity(0.2)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isTablet ? 24 : 20,
                          height: isTablet ? 24 : 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : AppColors.grey400,
                              width: 2,
                            ),
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            level,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFFFA500)
                                  : AppColors.grey700,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                        Icon(
                          _getExperienceIcon(level),
                          color: isSelected
                              ? const Color(0xFFFFA500)
                              : AppColors.grey400,
                          size: isTablet ? 24 : 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFA500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: const Color(0xFFFFA500),
                    size: isTablet ? 32 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell Your Story',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share your plant journey and expertise',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Bio text field
          TextField(
            controller: _bioController,
            maxLines: 8,
            maxLength: 500,
            decoration: InputDecoration(
              hintText:
                  'Tell us about your plant journey, areas of expertise, and what makes you passionate about plants...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: isTablet ? 14 : 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
              counterStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: isTablet ? 12 : 11,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isTablet ? 16 : 14,
              height: 1.5,
            ),
            onChanged: (value) {
              setState(() {
                _bio = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // Credentials section
          Text(
            'Credentials (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add any certifications, degrees, or professional credentials',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey600,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
          const SizedBox(height: 16),
          // Add credential field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _credentialController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Certified Horticulturist',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: isTablet ? 14 : 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700),
                      const Color(0xFFFFA500),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_credentialController.text.trim().isNotEmpty) {
                      setState(() {
                        _credentials.add(_credentialController.text.trim());
                        _credentialController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Display added credentials
          if (_credentials.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _credentials.map((credential) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 10,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: const Color(0xFFFFA500),
                        size: isTablet ? 16 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        credential,
                        style: TextStyle(
                          color: const Color(0xFFFFA500),
                          fontSize: isTablet ? 12 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _credentials.remove(credential);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: const Color(0xFFFFA500),
                          size: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFA500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.preview,
                    color: const Color(0xFFFFA500),
                    size: isTablet ? 32 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Application',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please review your information before submitting',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Review cards
          _buildReviewCard(
            'Specialty',
            _selectedSpecialty,
            Icons.psychology,
            isTablet,
            () => _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Experience',
            _experience,
            Icons.timeline,
            isTablet,
            () => _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'Bio',
            _bioController.text.length > 100
                ? '${_bioController.text.substring(0, 100)}...'
                : _bioController.text,
            Icons.edit_note,
            isTablet,
            () => _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          if (_credentials.isNotEmpty) ..._buildCredentialsSection(isTablet),
          const SizedBox(height: 24),
          // Benefits preview
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFA500).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: const Color(0xFFFFA500),
                      size: isTablet ? 24 : 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expert Benefits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildBenefitsList(isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String title,
    String content,
    IconData icon,
    bool isTablet,
    VoidCallback onEdit,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFA500),
                size: isTablet ? 20 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit,
                  color: AppColors.grey500,
                  size: isTablet ? 20 : 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey700,
              fontSize: isTablet ? 14 : 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBenefitsList(bool isTablet) {
    final benefits = [
      'Verified Expert Badge',
      'Priority in community answers',
      'Access to expert-only features',
      'Earn from helping others',
      'Build your professional reputation',
    ];

    return benefits
        .map(
          (benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFFFFA500),
                  size: isTablet ? 16 : 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      color: AppColors.grey700,
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'Indoor Plant Care':
        return Icons.home;
      case 'Outdoor Gardening':
        return Icons.yard;
      case 'Succulent & Cacti':
        return Icons.spa;
      case 'Plant Disease & Pests':
        return Icons.bug_report;
      case 'Plant Propagation':
        return Icons.content_copy;
      case 'Hydroponics':
        return Icons.water;
      case 'Organic Gardening':
        return Icons.eco;
      case 'Tropical Plants':
        return Icons.wb_sunny;
      case 'Herbs & Vegetables':
        return Icons.restaurant;
      case 'Landscaping Design':
        return Icons.landscape;
      default:
        return Icons.eco;
    }
  }

  IconData _getExperienceIcon(String experience) {
    switch (experience) {
      case '1-2 years':
        return Icons.local_florist;
      case '3-5 years':
        return Icons.local_florist;
      case '5-10 years':
        return Icons.park;
      case '10+ years':
        return Icons.forest;
      case 'Professional/Certified':
        return Icons.verified;
      default:
        return Icons.eco;
    }
  }

  List<Widget> _buildCredentialsSection(bool isTablet) {
    return [
      const SizedBox(height: 12),
      Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: const Color(0xFFFFA500),
                  size: isTablet ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Credentials',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.grey500,
                    size: isTablet ? 20 : 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _credentials.map((credential) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8 : 6,
                    vertical: isTablet ? 4 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    credential,
                    style: TextStyle(
                      color: const Color(0xFFFFA500),
                      fontSize: isTablet ? 11 : 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  void _submitApplication() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;
    
    if (currentUser == null) {
      _showErrorDialog('Authentication Error', 'Please sign in to submit your application.');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Submitting your application...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      // Create expert application object
      final expertApplication = ExpertApplication(
        userId: currentUser.id,
        userEmail: currentUser.email,
        userName: currentUser.name,
        specialty: _selectedSpecialty,
        experience: _experience,
        bio: _bioController.text.trim(),
        credentials: List<String>.from(_credentials),
        status: ExpertApplicationStatus.pending,
      );

      // Submit the application using the notifier
      await ref.read(expertApplicationNotifierProvider.notifier).submitApplication(expertApplication);
      
      // Check if submission was successful
      final submissionState = ref.read(expertApplicationNotifierProvider);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      submissionState.when(
        data: (applicationId) {
          if (applicationId != null) {
            _showSuccessDialog(applicationId);
          } else {
            _showErrorDialog('Submission Error', 'Failed to submit application. Please try again.');
          }
        },
        loading: () {
          // Still loading, should not reach here
        },
        error: (error, stackTrace) {
          _showErrorDialog('Submission Error', error.toString());
        },
      );
      
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      _showErrorDialog('Submission Error', 'An unexpected error occurred: $e');
    }
  }

  void _showSuccessDialog(String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for applying to become an expert! We\'ll review your application and get back to you within 3-5 business days.',
              style: TextStyle(
                height: 1.4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Application ID: ${applicationId.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close wizard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            height: 1.4,
            fontSize: 14,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

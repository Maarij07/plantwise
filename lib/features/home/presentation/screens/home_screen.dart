import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/user_constants.dart';
import '../../../../core/utils/time_greeting_utils.dart';
import '../../../../core/providers/care_streak_providers.dart';
import '../../../../core/services/care_streak_service.dart';
import '../widgets/weather_welcome_header.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../plants/presentation/screens/my_plants_screen.dart';
import '../../../plants/presentation/screens/camera_plant_screen.dart';
import '../../../plants/domain/models/plant.dart';
import '../../../plants/presentation/providers/plants_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          _DashboardTab(),
          MyPlantsScreen(),
          CommunityScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'My Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> with TickerProviderStateMixin {
  // Avatar seed - using UserConstants
  String _currentAvatarSeed = UserConstants.avatarSeed;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _getTimeBasedGreeting() {
    return TimeGreetingUtils.getShortGreeting();
  }

  String _getMotivationalMessage() {
    return TimeGreetingUtils.getMotivationalMessage();
  }

  // Build unified avatar - consistent across app
  Widget _buildDefaultAvatar(double size) {
    // Simple safe avatar that doesn't depend on async providers
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1024;
    
    // Responsive padding based on screen size
    final horizontalPadding = isLargeScreen 
        ? 32.0 
        : isTablet 
            ? 24.0 
            : AppConstants.paddingMedium;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: isTablet ? 28 : 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: isTablet ? 28 : 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: isTablet ? 10 : 8,
                    height: isTablet ? 10 : 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            ),
          ),
          if (isTablet) SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _buildQuickActionsFAB(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: isLargeScreen 
              ? _buildLargeScreenLayout(context, horizontalPadding)
              : _buildMobileLayout(context, horizontalPadding),
        ),
      ),
    );
  }

  // Mobile Layout (Default)
  Widget _buildMobileLayout(BuildContext context, double horizontalPadding) {
    return CustomScrollView(
      slivers: [
        // Enhanced Welcome Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppConstants.paddingMedium,
            ),
            child: const WeatherWelcomeHeader(),
          ),
        ),

        // Quick Stats Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildResponsiveStatsSection(context),
          ),
        ),

        // Plant Health Overview
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: _buildResponsivePlantHealthOverview(context),
          ),
        ),

        // Today's Tasks
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: _buildResponsiveTodaysTasks(context),
          ),
        ),

        // Weather & Environment
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: _buildResponsiveWeatherWidget(context),
          ),
        ),

        // Recent Activity Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: _buildResponsiveRecentActivity(context),
          ),
        ),

        // Achievement Streaks
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: _buildResponsiveAchievementStreaks(context),
          ),
        ),

        // Bottom padding for FAB and bottom navigation
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  // Large Screen Layout (Desktop/Tablet Landscape)
  Widget _buildLargeScreenLayout(BuildContext context, double horizontalPadding) {
    return CustomScrollView(
      slivers: [
        // Enhanced Welcome Header - Full Width
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppConstants.paddingMedium,
            ),
            child: _buildResponsiveWelcomeHeader(context),
          ),
        ),

        // Two Column Layout for Large Screens
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildResponsiveStatsSection(context),
                      const SizedBox(height: 24),
                      _buildResponsivePlantHealthOverview(context),
                      const SizedBox(height: 24),
                      _buildResponsiveWeatherWidget(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildResponsiveTodaysTasks(context),
                      const SizedBox(height: 24),
                      _buildResponsiveRecentActivity(context),
                      const SizedBox(height: 24),
                      _buildResponsiveAchievementStreaks(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Responsive Welcome Header
  Widget _buildResponsiveWelcomeHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements - scaled for screen size
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: isTablet ? 120 : 100,
              height: isTablet ? 120 : 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 35 : 25,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: isTablet ? 32 : 22,
                        backgroundColor: AppColors.background,
                        child: _buildDefaultAvatar(isTablet ? 64 : 44),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTimeBasedGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                          Text(
                            UserConstants.defaultUserName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Weather info - responsive sizing
                    Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: isTablet ? 28 : 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24°C',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Your garden is thriving! 🌱',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 20 : 16,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      size: isTablet ? 20 : 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15 plants • 3 tasks due today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isTablet ? 16 : 12,
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

  // Enhanced Welcome Header with Avatar & Weather
  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTimeBasedGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            UserConstants.defaultUserName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Weather info
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24°C',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your garden is thriving! 🌱',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15 plants • 3 tasks due today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
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

  // Enhanced Stats Section with Progress Indicators
  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Garden Overview',
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
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Total Plants',
                value: '15',
                progress: 0.75,
                icon: Icons.eco,
                color: AppColors.success,
                trend: '+3 this month',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Need Water',
                value: '3',
                progress: 0.3,
                icon: Icons.water_drop,
                color: AppColors.info,
                trend: '-1 from yesterday',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Health Score',
                value: '89%',
                progress: 0.89,
                icon: Icons.favorite,
                color: AppColors.primary,
                trend: '+5% this week',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Care Streak',
                value: '7d',
                progress: 0.7,
                icon: Icons.local_fire_department,
                color: AppColors.warning,
                trend: 'Keep it up!',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Plant Health Overview Widget
  Widget _buildPlantHealthOverview(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plant Health Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Excellent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthStatusItem(
                    'Healthy', 12, AppColors.success, Icons.favorite),
                ),
                Expanded(
                  child: _buildHealthStatusItem(
                    'Needs Care', 2, AppColors.warning, Icons.healing),
                ),
                Expanded(
                  child: _buildHealthStatusItem(
                    'Critical', 1, AppColors.error, Icons.warning),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.water_drop, size: 18),
                    label: const Text('Water All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Schedule'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Today's Tasks
  Widget _buildTodaysTasks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '3 pending',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEnhancedTaskCard(
          context,
          title: 'Water Monstera Deliciosa',
          subtitle: 'Living Room',
          timeInfo: 'Due in 2 hours',
          icon: Icons.water_drop,
          priority: 'high',
          plantImage: Icons.eco, // In real app, this would be an image
        ),
        const SizedBox(height: 8),
        _buildEnhancedTaskCard(
          context,
          title: 'Fertilize Snake Plant',
          subtitle: 'Bedroom',
          timeInfo: 'Due today',
          icon: Icons.grass,
          priority: 'medium',
          plantImage: Icons.eco,
        ),
        const SizedBox(height: 8),
        _buildEnhancedTaskCard(
          context,
          title: 'Health Check - Fiddle Leaf Fig',
          subtitle: 'Office',
          timeInfo: 'Weekly check',
          icon: Icons.visibility,
          priority: 'low',
          plantImage: Icons.eco,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Weather Widget
  Widget _buildWeatherWidget(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Garden Conditions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildConditionItem(
                    context, 'Temperature', '24°C', Icons.thermostat, AppColors.warning),
                ),
                Expanded(
                  child: _buildConditionItem(
                    context, 'Humidity', '65%', Icons.water_drop, AppColors.info),
                ),
                Expanded(
                  child: _buildConditionItem(
                    context, 'UV Index', '7', Icons.wb_sunny, AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perfect conditions for watering! Morning is ideal.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
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

  // Recent Activity Timeline
  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            _buildActivityItem(
              context,
              'Watered Monstera Deliciosa',
              '2 hours ago',
              Icons.water_drop,
              AppColors.info,
            ),
            _buildActivityItem(
              context,
              'Added new Snake Plant',
              '1 day ago',
              Icons.add_circle,
              AppColors.success,
            ),
            _buildActivityItem(
              context,
              'Earned "Green Thumb" badge',
              '2 days ago',
              Icons.emoji_events,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  // Achievement Streaks Section
  Widget _buildAchievementStreaks(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements & Streaks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementItem(
                    context,
                    'Care Streak',
                    '7 days',
                    Icons.local_fire_department,
                    AppColors.error,
                    0.7,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAchievementItem(
                    context,
                    'Weekly Goal',
                    '5/7 tasks',
                    Icons.track_changes,
                    AppColors.primary,
                    5/7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recent Badges',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge(Icons.eco, 'Green Thumb'),
                const SizedBox(width: 12),
                _buildBadge(Icons.water_drop, 'Hydro Hero'),
                const SizedBox(width: 12),
                _buildBadge(Icons.favorite, 'Plant Parent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Quick Actions FAB
  Widget _buildQuickActionsFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActionsMenu(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add),
      label: const Text('Quick Actions'),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context, 'Take Photo', Icons.camera_alt, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraPlantScreen(),
                      ),
                    );
                  }),
                _buildQuickActionButton(
                  context, 'Water Plants', Icons.water_drop, () {
                    Navigator.pop(context);
                    _showWaterPlantsDialog(context);
                  }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper methods for dashboard components
  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(icon, color: AppColors.primary),
              onPressed: onPressed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Responsive stats section
  Widget _buildResponsiveStatsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1024;
    
    return Consumer(
      builder: (context, ref, child) {
        final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
        
        return dashboardStatsAsync.when(
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Garden Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 22 : 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              // Stats grid - responsive layout
              isLargeScreen 
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Total Plants',
                                value: stats.totalPlants.toString(),
                                progress: (stats.totalPlants / 20).clamp(0.0, 1.0), // Progress out of 20 max plants
                                icon: Icons.eco,
                                color: AppColors.success,
                                trend: 'Growing strong',
                                isPositive: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Need Water',
                                value: stats.plantsNeedingWater.toString(),
                                progress: stats.totalPlants > 0 
                                    ? (stats.plantsNeedingWater / stats.totalPlants).clamp(0.0, 1.0)
                                    : 0.0,
                                icon: Icons.water_drop,
                                color: AppColors.info,
                                trend: stats.plantsNeedingWater == 0 ? 'All watered!' : 'Needs attention',
                                isPositive: stats.plantsNeedingWater == 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Health Score',
                                value: stats.healthScorePercentage,
                                progress: stats.overallHealthScore / 100,
                                icon: Icons.favorite,
                                color: AppColors.primary,
                                trend: stats.healthStatusDescription,
                                isPositive: stats.overallHealthScore >= 75,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Care Streak',
                                value: stats.streakDescription,
                                progress: (stats.careStreak / 30).clamp(0.0, 1.0), // Progress out of 30 days max
                                icon: Icons.local_fire_department,
                                color: AppColors.warning,
                                trend: stats.careStreak > 0 ? 'Keep it up!' : 'Start caring!',
                                isPositive: stats.careStreak > 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Total Plants',
                                value: stats.totalPlants.toString(),
                                progress: (stats.totalPlants / 20).clamp(0.0, 1.0),
                                icon: Icons.eco,
                                color: AppColors.success,
                                trend: 'Growing strong',
                                isPositive: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Need Water',
                                value: stats.plantsNeedingWater.toString(),
                                progress: stats.totalPlants > 0 
                                    ? (stats.plantsNeedingWater / stats.totalPlants).clamp(0.0, 1.0)
                                    : 0.0,
                                icon: Icons.water_drop,
                                color: AppColors.info,
                                trend: stats.plantsNeedingWater == 0 ? 'All watered!' : 'Needs attention',
                                isPositive: stats.plantsNeedingWater == 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Health Score',
                                value: stats.healthScorePercentage,
                                progress: stats.overallHealthScore / 100,
                                icon: Icons.favorite,
                                color: AppColors.primary,
                                trend: stats.healthStatusDescription,
                                isPositive: stats.overallHealthScore >= 75,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                context,
                                title: 'Care Streak',
                                value: stats.streakDescription,
                                progress: (stats.careStreak / 30).clamp(0.0, 1.0),
                                icon: Icons.local_fire_department,
                                color: AppColors.warning,
                                trend: stats.careStreak > 0 ? 'Keep it up!' : 'Start caring!',
                                isPositive: stats.careStreak > 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              SizedBox(height: isTablet ? 32 : 24),
            ],
          ),
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Garden Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 22 : 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              // Loading skeleton
              _buildStatsLoadingSkeleton(isLargeScreen),
              SizedBox(height: isTablet ? 32 : 24),
            ],
          ),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Garden Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 22 : 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              // Error state
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load garden stats',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),
            ],
          ),
        );
      },
    );
  }

  // Loading skeleton for stats section
  Widget _buildStatsLoadingSkeleton(bool isLargeScreen) {
    return isLargeScreen
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSkeletonCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSkeletonCard()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSkeletonCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSkeletonCard()),
                ],
              ),
            ],
          )
        : Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSkeletonCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSkeletonCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSkeletonCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSkeletonCard()),
                ],
              ),
            ],
          );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced stat card widget
  Widget _buildEnhancedStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required double progress,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detailed stats
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trend,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add other responsive dashboard methods
  Widget _buildResponsivePlantHealthOverview(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Plant Health Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12, 
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Excellent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              children: [
                Expanded(
                  child: _buildResponsiveHealthStatusItem(
                    'Healthy', 12, AppColors.success, Icons.favorite, isTablet),
                ),
                Expanded(
                  child: _buildResponsiveHealthStatusItem(
                    'Needs Care', 2, AppColors.warning, Icons.healing, isTablet),
                ),
                Expanded(
                  child: _buildResponsiveHealthStatusItem(
                    'Critical', 1, AppColors.error, Icons.warning, isTablet),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.water_drop, size: isTablet ? 20 : 18),
                    label: Text(
                      'Water All',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                        horizontal: isTablet ? 24 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.schedule, size: isTablet ? 20 : 18),
                    label: Text(
                      'Schedule',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                        horizontal: isTablet ? 24 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHealthStatusItem(
    String label, 
    int count, 
    Color color, 
    IconData icon, 
    bool isTablet,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: Icon(icon, color: color, size: isTablet ? 24 : 20),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Add remaining responsive methods as needed
  Widget _buildResponsiveTodaysTasks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveWeatherWidget(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.wb_sunny, size: 40, color: AppColors.warning),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('24°C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      'Sunny',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRecentActivity(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveAchievementStreaks(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add missing helper methods
  Widget _buildHealthStatusItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedTaskCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String timeInfo,
    required IconData icon,
    required String priority,
    required IconData plantImage,
  }) {
    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = AppColors.error;
        break;
      case 'medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.success;
    }

    return Card(
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(plantImage, color: AppColors.primary),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$subtitle • $timeInfo',
          style: TextStyle(color: priorityColor),
        ),
        trailing: IconButton(
          icon: Icon(icon, color: AppColors.primary),
          onPressed: () {
            // TODO: Perform quick action
          },
        ),
        onTap: () {
          // TODO: Navigate to task details
        },
      ),
    );
  }

  Widget _buildConditionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods for quick actions
  void _showWaterPlantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.water_drop, color: AppColors.info),
            const SizedBox(width: 8),
            const Text('Water Plants'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select plants to water:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Mock plant list
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.eco, color: AppColors.primary),
              ),
              title: const Text('Monstera Deliciosa'),
              subtitle: const Text('Living Room • Needs water'),
              trailing: Checkbox(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.eco, color: AppColors.primary),
              ),
              title: const Text('Snake Plant'),
              subtitle: const Text('Bedroom • Needs water'),
              trailing: Checkbox(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plants watered successfully! 💧'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
            ),
            child: const Text('Water Selected'),
          ),
        ],
      ),
    );
  }

  void _showRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Reminders'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upcoming plant care reminders:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Mock reminders list
            ListTile(
              leading: Icon(Icons.water_drop, color: AppColors.info),
              title: const Text('Water Monstera'),
              subtitle: const Text('Today at 9:00 AM'),
            ),
            ListTile(
              leading: Icon(Icons.grass, color: AppColors.success),
              title: const Text('Fertilize Snake Plant'),
              subtitle: const Text('Tomorrow at 10:00 AM'),
            ),
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.warning),
              title: const Text('Health Check'),
              subtitle: const Text('In 3 days'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to reminders screen
            },
            child: const Text('Manage Reminders'),
          ),
        ],
      ),
    );
  }

  void _showPlantCareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.favorite, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Plant Care Tips'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick care tips for today:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildCareTip(Icons.wb_sunny, 'Perfect lighting conditions today', AppColors.warning),
            const SizedBox(height: 8),
            _buildCareTip(Icons.water_drop, 'Morning is ideal for watering', AppColors.info),
            const SizedBox(height: 8),
            _buildCareTip(Icons.thermostat, 'Temperature is optimal for growth', AppColors.success),
            const SizedBox(height: 8),
            _buildCareTip(Icons.air, 'Good humidity levels detected', AppColors.primary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to care guide
            },
            child: const Text('View Care Guide'),
          ),
        ],
      ),
    );
  }

  void _showHealthCheckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Plant Health Check'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recent health assessments:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Mock health status
            _buildHealthStatusTile('Monstera Deliciosa', 'Excellent', AppColors.success, Icons.favorite),
            _buildHealthStatusTile('Snake Plant', 'Good', AppColors.primary, Icons.eco),
            _buildHealthStatusTile('Fiddle Leaf Fig', 'Needs Attention', AppColors.warning, Icons.healing),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to My Plants tab
              final homeScreen = context.findAncestorStateOfType<_HomeScreenState>();
              homeScreen?._onTabTapped(1);
            },
            child: const Text('View All Plants'),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatusTile(String plantName, String status, Color color, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        radius: 16,
        child: Icon(icon, color: color, size: 16),
      ),
      title: Text(
        plantName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

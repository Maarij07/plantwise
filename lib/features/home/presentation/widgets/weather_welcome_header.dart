import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/weather_data.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/constants/user_constants.dart';
import '../../../../core/utils/time_greeting_utils.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/avatar_provider.dart';
import '../../../../config/theme/app_theme.dart';
import '../providers/weather_provider.dart';

// Weather Provider
final weatherDataProvider = FutureProvider<WeatherData>((ref) async {
  return await WeatherService.getCurrentWeather();
});

// Weather refresh provider
final weatherRefreshProvider = StateProvider<int>((ref) => 0);

class WeatherWelcomeHeader extends ConsumerStatefulWidget {
  const WeatherWelcomeHeader({super.key});

  @override
  ConsumerState<WeatherWelcomeHeader> createState() => _WeatherWelcomeHeaderState();
}

class _WeatherWelcomeHeaderState extends ConsumerState<WeatherWelcomeHeader> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _currentAvatarSeed = UserConstants.avatarSeed;
  Timer? _weatherRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startWeatherRefreshTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  void _startWeatherRefreshTimer() {
    // Refresh weather data every 15 minutes
    _weatherRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (timer) {
        // Trigger weather data refresh
        ref.read(weatherRefreshProvider.notifier).state++;
        print('🌦️ Weather data auto-refreshed at ${DateTime.now()}');
      },
    );
  }

  @override
  void dispose() {
    _weatherRefreshTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildLoadingHeader(BuildContext context, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      width: double.infinity,
      height: isTablet ? 180 : 150,
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
        clipBehavior: Clip.hardEdge,
        children: [
          // Loading shimmer effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Loading content
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        child: _buildDefaultAvatar(context, isTablet ? 64 : 44),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TimeGreetingUtils.getShortGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Loading weather widget
                    Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Loading...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: isTablet ? 12 : 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Preparing your garden insights...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 20 : 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHeader(BuildContext context, String error, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      width: double.infinity,
      height: isTablet ? 180 : 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.8),
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    child: _buildDefaultAvatar(context, isTablet ? 64 : 44),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TimeGreetingUtils.getShortGreeting(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isTablet ? 18 : 14,
                        ),
                      ),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: isTablet ? 28 : 24,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Refresh weather data
                    ref.read(weatherRefreshProvider.notifier).state++;
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherHeader(BuildContext context, WeatherData weather, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Default weather message if provider fails
    String defaultMessage = "Your garden is thriving! 🌱";
    String weatherMessage;
    
    try {
      weatherMessage = WeatherService.getWeatherMessage(weather.condition);
    } catch (e) {
      print('Error getting weather message: $e');
      weatherMessage = defaultMessage;
    }
    
    // Safe avatar URL getter
    String? avatarUrl;
    try {
      avatarUrl = ref.watch(avatarUrlProvider);
    } catch (e) {
      print('Error getting avatar URL: $e');
      avatarUrl = "https://api.dicebear.com/7.x/micah/svg?seed=${_currentAvatarSeed}";
    }
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isTablet ? 180 : 150,
        maxHeight: isTablet ? 220 : 200,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: weather.condition.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: weather.condition.primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          // Background decorations based on weather
          _buildWeatherBackgroundDecorations(weather.condition, isTablet),
          // Main content
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildUserAvatarWithWeather(avatarUrl, isTablet),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUserGreeting(context, userName, isTablet),
                    ),
                    _buildWeatherInfo(context, weather, isTablet),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
                _buildWeatherMessage(context, weatherMessage, isTablet),
                SizedBox(height: isTablet ? 12 : 8),
                _buildPlantStats(context, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBackgroundDecorations(WeatherCondition condition, bool isTablet) {
    return Stack(
      children: [
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
            child: Icon(
              condition.icon,
              color: Colors.white.withOpacity(0.2),
              size: isTablet ? 60 : 50,
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
      ],
    );
  }

  Widget _buildUserAvatarWithWeather(String? avatarUrl, bool isTablet) {
    return CircleAvatar(
      radius: isTablet ? 35 : 25,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: isTablet ? 32 : 22,
        backgroundColor: AppColors.background,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        onBackgroundImageError: (_, __) {
          // Fallback handled by the child below
        },
        child: avatarUrl == null
            ? _buildDefaultAvatar(context, isTablet ? 64 : 44)
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
              ),
      ),
    );
  }

  Widget _buildUserGreeting(BuildContext context, String userName, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TimeGreetingUtils.getShortGreeting(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: isTablet ? 18 : 14,
          ),
        ),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 28 : 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(BuildContext context, WeatherData weather, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Column(
        children: [
          Icon(
            weather.condition.icon,
            color: Colors.white,
            size: isTablet ? 28 : 20,
          ),
          const SizedBox(height: 4),
          Text(
            weather.temperatureString,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMessage(BuildContext context, String message, bool isTablet) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white.withOpacity(0.9),
        fontSize: isTablet ? 20 : 16,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPlantStats(BuildContext context, bool isTablet) {
    return Row(
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
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, double? size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final avatarSize = size ?? (isTablet ? 64 : 44);
    
    // Simple safe avatar that doesn't depend on async providers
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: avatarSize * 0.5,
        color: AppColors.primary,
      ),
    );
  }

  // BULLETPROOF SIMPLE METHODS - ZERO layout issues guaranteed
  Widget _buildSimpleLoadingHeader(BuildContext context, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 30 : 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: isTablet ? 30 : 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeGreetingUtils.getShortGreeting(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 12,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading garden insights... 🌱',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleErrorHeader(BuildContext context, String error, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.withOpacity(0.8), Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 30 : 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: isTablet ? 30 : 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeGreetingUtils.getShortGreeting(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 12,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your garden is thriving! 🌱',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(weatherRefreshProvider.notifier).state++,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleWeatherHeader(BuildContext context, WeatherData weather, String userName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    String weatherMessage = 'Your garden is thriving! 🌱';
    try {
      weatherMessage = WeatherService.getWeatherMessage(weather.condition);
    } catch (e) {
      // Use default message
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: weather.condition.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: isTablet ? 30 : 20, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TimeGreetingUtils.getShortGreeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 16 : 12,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      weather.condition.icon,
                      color: Colors.white,
                      size: isTablet ? 24 : 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.temperatureString,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 14 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            weatherMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for refresh changes
    ref.watch(weatherRefreshProvider);
    
    final weatherAsync = ref.watch(weatherDataProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SizedBox(
      width: double.infinity,
      height: isTablet ? 200 : 170, // BULLETPROOF: Fixed height, no constraints issues
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: currentUserAsync.when(
            loading: () => _buildSimpleLoadingHeader(context, UserConstants.defaultUserName),
            error: (error, stack) => _buildSimpleErrorHeader(context, error.toString(), UserConstants.defaultUserName),
            data: (user) {
              final userName = user?.name ?? UserConstants.defaultUserName;
              return weatherAsync.when(
                loading: () => _buildSimpleLoadingHeader(context, userName),
                error: (error, stack) => _buildSimpleErrorHeader(context, error.toString(), userName),
                data: (weather) => _buildSimpleWeatherHeader(context, weather, userName),
              );
            },
          ),
        ),
      ),
    );
  }
}

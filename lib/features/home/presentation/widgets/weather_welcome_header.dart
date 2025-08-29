import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/weather_data.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/constants/user_constants.dart';
import '../../../../core/utils/time_greeting_utils.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../features/authentication/presentation/providers/auth_providers.dart';
import 'dynamic_user_avatar.dart';
import 'weather_designs/sunny_header.dart';
import 'weather_designs/rainy_header.dart';
import 'weather_designs/thunderstorm_header.dart';
import 'weather_designs/cloudy_header.dart';
import 'weather_designs/snowy_header.dart';
import 'weather_designs/foggy_header.dart';
import 'weather_designs/windy_header.dart';
import 'weather_designs/partly_cloudy_header.dart';

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

  String _getUserDisplayName() {
    // Get current user from auth provider
    final currentUserAsync = ref.watch(currentUserProvider);
    return currentUserAsync.when(
      data: (user) => user?.name ?? UserConstants.defaultUserName,
      loading: () => UserConstants.defaultUserName,
      error: (_, __) => UserConstants.defaultUserName,
    );
  }

  Widget _buildLoadingHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final userName = _getUserDisplayName();
    
    return Container(
      width: double.infinity,
      height: isTablet ? 230 : 190,
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
                        child: _buildDynamicAvatar(isTablet ? 64 : 44),
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
                const Spacer(),
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

  Widget _buildErrorHeader(BuildContext context, String error) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final userName = _getUserDisplayName();
    
    return Container(
      width: double.infinity,
      height: isTablet ? 230 : 190,
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
                    child: _buildDynamicAvatar(isTablet ? 64 : 44),
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
            const Spacer(),
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

  Widget _buildWeatherHeader(BuildContext context, WeatherData weather) {
    final userName = _getUserDisplayName();
    
    // Select the appropriate weather design based on condition
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return SunnyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.rainy:
        return RainyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.thunderstorm:
        return ThunderstormHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.cloudy:
        return CloudyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.snowy:
        return SnowyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.foggy:
        return FoggyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.windy:
        return WindyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
      case WeatherCondition.partlyCloudy:
      default:
        return PartlyCloudyHeader(
          weather: weather,
          greeting: TimeGreetingUtils.getShortGreeting(),
          userName: userName,
          avatar: _buildDynamicAvatar(null),
          message: WeatherService.getWeatherMessage(weather.condition),
        );
    }
  }

  Widget _buildDynamicAvatar(double? size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final avatarSize = size ?? (isTablet ? 64 : 44);
    
    return DynamicUserAvatar(
      size: avatarSize,
      fallback: Icon(
        Icons.person,
        size: avatarSize * 0.5,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for refresh changes
    ref.watch(weatherRefreshProvider);
    
    final weatherAsync = ref.watch(weatherDataProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: weatherAsync.when(
          loading: () => _buildLoadingHeader(context),
          error: (error, stack) => _buildErrorHeader(context, error.toString()),
          data: (weather) => _buildWeatherHeader(context, weather),
        ),
      ),
    );
  }
}
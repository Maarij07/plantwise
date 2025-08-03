class AppConstants {
  // App Info
  static const String appName = 'PlantWise';
  static const String appVersion = '1.0.0';
  
  // Admin Credentials
  static const String adminEmail = 'admin@gmail.com';
  static const String adminPassword = '12345678';
  
  // Routes
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String signInRoute = '/sign-in';
  static const String signUpRoute = '/sign-up';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String adminRoute = '/admin';
  
  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1Path = 'assets/images/onboarding1.png';
  static const String onboarding2Path = 'assets/images/onboarding2.png';
  static const String onboarding3Path = 'assets/images/onboarding3.png';
  
  // Onboarding Content
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to PlantWise',
      'description': 'Your personal guide to plant care and gardening success. Discover, learn, and grow with confidence.',
      'image': onboarding1Path,
    },
    {
      'title': 'Smart Plant Care',
      'description': 'Get personalized care reminders, expert tips, and plant health monitoring to keep your plants thriving.',
      'image': onboarding2Path,
    },
    {
      'title': 'Join the Community',
      'description': 'Connect with fellow plant lovers, share your garden journey, and get support from experts.',
      'image': onboarding3Path,
    },
  ];
}

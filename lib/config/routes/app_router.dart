import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/sign_in_screen.dart';
import '../../features/authentication/presentation/screens/sign_up_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../features/authentication/data/services/auth_storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) async {
      // Allow splash screen to handle its own logic
      if (state.matchedLocation == AppConstants.splashRoute) {
        return null;
      }
      
      // Allow onboarding and auth routes to be accessed without login
      final allowedWithoutLogin = [
        AppConstants.onboardingRoute,
        AppConstants.signInRoute,
        AppConstants.signUpRoute,
        AppConstants.forgotPasswordRoute,
      ];
      
      if (allowedWithoutLogin.contains(state.matchedLocation)) {
        return null;
      }
      
      // For protected routes, check if user is logged in
      final isLoggedIn = await AuthStorageService.instance.isLoggedIn();
      if (!isLoggedIn) {
        // If not logged in, check if they've seen onboarding
        final isFirstLaunch = await AuthStorageService.instance.isFirstLaunch();
        return isFirstLaunch ? AppConstants.onboardingRoute : AppConstants.signInRoute;
      }
      
      // Allow access to protected routes if logged in
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding Screen
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: AppConstants.signInRoute,
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppConstants.signUpRoute,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.adminRoute,
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      
      // Profile Routes
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.splashRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

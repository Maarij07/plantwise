import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/widgets/bitmoji_avatar.dart';
import '../../../profile/presentation/providers/avatar_provider.dart';
import '../../../profile/data/services/avatar_service.dart';
import '../../../../core/constants/user_constants.dart';

/// Dynamic avatar widget that displays user's photo if available,
/// otherwise shows generated Bitmoji avatar based on user data
class DynamicUserAvatar extends ConsumerWidget {
  final double size;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Widget? fallback;
  final bool showLoadingIndicator;

  const DynamicUserAvatar({
    super.key,
    this.size = 80,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.fallback,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        child: currentUserAsync.when(
          data: (user) {
            // If user has a profile photo, display it
            if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
              return _buildUserPhoto(user.photoUrl!, ref);
            }
            
            // Otherwise, generate a consistent avatar from user data
            return _buildGeneratedAvatar(user, ref);
          },
          loading: () => _buildLoadingPlaceholder(),
          error: (_, __) => _buildErrorFallback(),
        ),
      ),
    );
  }

  /// Build user's uploaded photo with error fallback
  Widget _buildUserPhoto(String photoUrl, WidgetRef ref) {
    return CachedNetworkImage(
      imageUrl: photoUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        // If user photo fails to load, fallback to generated avatar
        final currentUserAsync = ref.watch(currentUserProvider);
        return currentUserAsync.when(
          data: (user) => _buildGeneratedAvatar(user, ref),
          loading: () => _buildLoadingPlaceholder(),
          error: (_, __) => _buildErrorFallback(),
        );
      },
    );
  }

  /// Build generated Bitmoji avatar from user data
  Widget _buildGeneratedAvatar(dynamic user, WidgetRef ref) {
    // Use the shared userAvatarProvider seed for consistency with profile page
    final avatarSeed = ref.watch(userAvatarProvider);
    
    return BitmojiAvatar(
      seed: avatarSeed,
      gender: _getUserGender(user),
      size: size,
      style: 'micah',
      customOptions: AvatarService.getPresetConfig('garden-theme'),
      fallback: fallback ?? _buildErrorFallback(),
    );
  }


  /// Determine user gender (can be extended to read from user preferences)
  String? _getUserGender(dynamic user) {
    // For now, return default gender
    // This can be extended to read from user profile preferences
    return UserConstants.defaultGender;
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: showLoadingIndicator 
            ? CircularProgressIndicator(
                strokeWidth: size > 50 ? 2 : 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.7)),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.primary.withOpacity(0.5),
              ),
      ),
    );
  }

  /// Build error fallback
  Widget _buildErrorFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}

/// User avatar provider that returns the appropriate avatar data
final userAvatarDataProvider = Provider<UserAvatarData>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  final avatarSeed = ref.watch(userAvatarProvider);
  
  return currentUserAsync.when(
    data: (user) => UserAvatarData(
      hasPhoto: user?.photoUrl != null && user!.photoUrl!.isNotEmpty,
      photoUrl: user?.photoUrl,
      generatedSeed: avatarSeed, // Use the shared avatar seed
      userName: user?.name ?? UserConstants.defaultUserName,
    ),
    loading: () => UserAvatarData.loading(),
    error: (_, __) => UserAvatarData.error(),
  );
});


/// Data class for user avatar information
class UserAvatarData {
  final bool hasPhoto;
  final String? photoUrl;
  final String generatedSeed;
  final String userName;
  final bool isLoading;
  final bool isError;

  const UserAvatarData({
    required this.hasPhoto,
    this.photoUrl,
    required this.generatedSeed,
    required this.userName,
    this.isLoading = false,
    this.isError = false,
  });

  factory UserAvatarData.loading() => const UserAvatarData(
    hasPhoto: false,
    generatedSeed: 'loading_seed',
    userName: 'Loading...',
    isLoading: true,
  );

  factory UserAvatarData.error() => const UserAvatarData(
    hasPhoto: false,
    generatedSeed: 'error_seed',
    userName: 'Error',
    isError: true,
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/services/avatar_service.dart';

// Avatar seed provider - generates a consistent seed from user data
final avatarSeedProvider = Provider<String>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return currentUserAsync.when(
    data: (user) {
      if (user != null && user.email != null) {
        // Generate consistent seed from user email and name
        final emailPart = user.email!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        final namePart = user.name?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') ?? 'user';
        return '${emailPart}_${namePart}'.toLowerCase();
      }
      return 'default_user_seed';
    },
    loading: () => 'loading_seed',
    error: (_, __) => 'error_seed',
  );
});

// Avatar URL provider - generates the actual avatar URL using Micah style
final avatarUrlProvider = Provider<String>((ref) {
  final seed = ref.watch(avatarSeedProvider);
  
  return AvatarService.generateAvatarUrl(
    seed: seed,
    style: 'micah', // Force Micah style
    size: 200,
    customOptions: {
      'backgroundColor': ['f0f9ff', 'e0f2fe', 'bae6fd'].join(','),
      'baseColor': ['f0f9ff', 'e0f2fe'].join(','),
    },
  );
});

// User avatar state provider for handling avatar changes
class UserAvatarNotifier extends StateNotifier<String> {
  UserAvatarNotifier(String initialSeed) : super(initialSeed);
  
  void updateSeed(String newSeed) {
    state = newSeed;
  }
  
  String getAvatarUrl({int size = 200}) {
    return AvatarService.generateAvatarUrl(
      seed: state,
      style: 'micah', // Always use Micah
      size: size,
      customOptions: {
        'backgroundColor': ['f0f9ff', 'e0f2fe', 'bae6fd'].join(','),
        'baseColor': ['f0f9ff', 'e0f2fe'].join(','),
      },
    );
  }
}

// User avatar provider with state management
final userAvatarProvider = StateNotifierProvider<UserAvatarNotifier, String>((ref) {
  final initialSeed = ref.watch(avatarSeedProvider);
  return UserAvatarNotifier(initialSeed);
});

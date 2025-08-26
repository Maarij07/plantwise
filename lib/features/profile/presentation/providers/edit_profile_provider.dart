import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/domain/entities/user.dart';

part 'edit_profile_provider.freezed.dart';

@freezed
class EditProfileState with _$EditProfileState {
  const factory EditProfileState.initial() = _Initial;
  const factory EditProfileState.loading() = _Loading;
  const factory EditProfileState.success(User user) = _Success;
  const factory EditProfileState.error(String message) = _Error;
}

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final Ref _ref;

  EditProfileNotifier(this._ref) : super(const EditProfileState.initial());

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    state = const EditProfileState.loading();
    
    try {
      // Validate input
      if (name != null && name.trim().isEmpty) {
        state = const EditProfileState.error('Name cannot be empty');
        return;
      }
      
      if (email != null && !_isValidEmail(email)) {
        state = const EditProfileState.error('Please enter a valid email address');
        return;
      }
      
      // Update user via AuthNotifier
      await _ref.read(authNotifierProvider.notifier).updateUser(
        userId: userId,
        name: name?.trim(),
        email: email?.trim(),
        photoUrl: null, // Don't update photoUrl from edit profile
      );
      
      // Force refresh the current user provider to get the latest data from Firestore
      _ref.invalidate(currentUserProvider);
      
      // Wait for the invalidation to trigger a fresh fetch
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get the updated user from auth state (which should now have the latest data)
      final authState = _ref.read(authStateProvider);
      authState.when(
        initial: () {
          state = const EditProfileState.error('Auth state is not initialized');
        },
        loading: () {
          state = const EditProfileState.error('Update in progress, please wait');
        },
        authenticated: (user) {
          // Success! The UI will now show the updated data
          state = EditProfileState.success(user);
        },
        unauthenticated: () {
          state = const EditProfileState.error('User is not authenticated');
        },
        error: (message) {
          state = EditProfileState.error('Update failed: $message');
        },
        passwordResetSent: () {
          state = const EditProfileState.error('Unexpected auth state');
        },
      );
      
      // If auth state doesn't have success yet, try to get fresh data from current user provider
      if (!state.maybeWhen(success: (_) => true, orElse: () => false)) {
        try {
          // Force a fresh read from the repository
          final repository = _ref.read(authRepositoryProvider);
          final freshUser = await repository.getCurrentUser();
          if (freshUser != null) {
            state = EditProfileState.success(freshUser);
          } else {
            state = const EditProfileState.error('Could not fetch updated user data');
          }
        } catch (e) {
          print('Error fetching fresh user data: $e');
          state = EditProfileState.error('Profile updated but could not refresh UI: $e');
        }
      }
      
    } catch (e) {
      state = EditProfileState.error(e.toString());
    }
  }
  
  void clearError() {
    if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
      state = const EditProfileState.initial();
    }
  }
  
  void reset() {
    state = const EditProfileState.initial();
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}

final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier(ref);
});

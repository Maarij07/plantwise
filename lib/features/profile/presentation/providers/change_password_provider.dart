import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

// Change password state
class ChangePasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Change password notifier
class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final Ref _ref;
  
  ChangePasswordNotifier(this._ref) : super(const ChangePasswordState());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      print('ChangePasswordNotifier: Starting password change');
      await _ref.read(authNotifierProvider.notifier).changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      print('ChangePasswordNotifier: Password change successful');
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      print('ChangePasswordNotifier: Password change error: $e');
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    }
  }

  void clearState() {
    state = const ChangePasswordState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider for change password state
final changePasswordProvider = StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>(
  (ref) => ChangePasswordNotifier(ref),
);

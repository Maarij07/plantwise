import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/services/auth_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Auth State Stream Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User Provider
final currentUserProvider = FutureProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

// Auth Controller
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState.initial());

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    try {
      final user = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Save login state to persistent storage
        await AuthStorageService.instance.saveLoginState(
          isLoggedIn: true,
          userId: user.id,
          email: user.email,
          name: user.name,
        );
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.error('Sign in failed');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthState.loading();
    
    try {
      final user = await _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      
      // Save login state to persistent storage
      await AuthStorageService.instance.saveLoginState(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        name: user.name,
      );
      
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    // Clear login state from persistent storage
    await AuthStorageService.instance.clearLoginState();
    await _repository.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email: email);
      // Could add a success state if needed
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  // Profile update functionality would need to be implemented in repository if needed
  // Future<void> updateProfile({
  //   String? displayName,
  //   String? photoUrl,
  // }) async {
  //   // Implementation would go here
  // }

  Future<void> clearError() async {
    if (state is AuthStateError) {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        state = AuthState.authenticated(currentUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    }
  }
}

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

// Convenience providers for common auth operations
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is AuthStateLoading;
});

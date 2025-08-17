import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/models/auth_result.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Auth State Stream Provider
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
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
    
    final result = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    result.when(
      success: (user) => state = AuthState.authenticated(user),
      failure: (message) => state = AuthState.error(message),
    );
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AuthState.loading();
    
    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    
    result.when(
      success: (user) => state = AuthState.authenticated(user),
      failure: (message) => state = AuthState.error(message),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    return await _repository.sendPasswordResetEmail(email);
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final result = await _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
    
    result.when(
      success: (user) => state = AuthState.authenticated(user),
      failure: (message) => state = AuthState.error(message),
    );
  }

  void clearError() {
    if (state is AuthError) {
      final currentUser = _repository.currentUser;
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
  return authState is AuthLoading;
});

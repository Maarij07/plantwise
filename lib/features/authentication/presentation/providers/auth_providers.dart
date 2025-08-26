import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart' as domain;
import 'auth_state.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data source provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDataSource: ref.watch(authDataSourceProvider),
  );
});

// Auth state notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

// Current user provider - fetches fresh data from Firestore
final currentUserProvider = StreamProvider<domain.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  // Transform the auth state changes stream to fetch fresh Firestore data
  return authRepository.authStateChanges.asyncMap((user) async {
    if (user == null) return null;
    
    // Fetch the latest user data from Firestore
    try {
      final freshUser = await authRepository.getCurrentUser();
      return freshUser;
    } catch (e) {
      print('Error fetching fresh user data: $e');
      // Fallback to the user from auth state if Firestore fails
      return user;
    }
  });
});

// Auth state provider for UI
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

// Refresh user data provider - useful for forcing a manual refresh
final refreshUserDataProvider = FutureProvider<domain.User?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState.initial()) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen(
      (user) async {
        print('Auth state stream listener: User changed to ${user?.email ?? 'null'}');
        if (user != null) {
          print('Auth state stream: User is authenticated, processing...');
          // Get current Remember Me preference
          final rememberMe = await AuthStorageService.instance.isRememberMeEnabled();
          print('Auth state stream: Remember me preference: $rememberMe');
          
          // Sync with AuthStorageService when user is authenticated
          await AuthStorageService.instance.saveLoginState(
            isLoggedIn: true,
            rememberMe: rememberMe,
            userId: user.id,
            email: user.email,
            name: user.name,
          );
          print('Auth state stream: Saved login state, setting auth state to authenticated');
          state = AuthState.authenticated(user);
          print('Auth state stream: Auth state set to authenticated for ${user.name}');
        } else {
          print('Auth state stream: User is null, clearing login state');
          // Clear AuthStorageService when user is unauthenticated
          await AuthStorageService.instance.clearLoginState();
          state = const AuthState.unauthenticated();
          print('Auth state stream: Auth state set to unauthenticated');
        }
      },
      onError: (error) {
        print('Auth stream error: $error');
        state = AuthState.error(error.toString());
      },
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    print('AuthNotifier: Starting sign-in process for $email');
    print('AuthNotifier: Remember me: $rememberMe');
    state = const AuthState.loading();
    try {
      // Save Remember Me preference before authentication
      print('AuthNotifier: Saving remember me preference: $rememberMe');
      await AuthStorageService.instance.setRememberMe(rememberMe);
      
      print('AuthNotifier: Calling repository sign-in method');
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('AuthNotifier: Repository sign-in completed successfully');
      // Don't set state manually - let the authStateChanges stream handle it
    } catch (e) {
      print('AuthNotifier: Sign-in error: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      // Don't set state manually - let the authStateChanges stream handle it
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _authRepository.signOut();
      // Clear storage service (this will also be done by the stream listener, but ensures cleanup)
      await AuthStorageService.instance.clearLoginState();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    print('AuthNotifier: Starting user update for $userId');
    state = const AuthState.loading();
    try {
      final updatedUser = await _authRepository.updateUser(
        userId: userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      print('AuthNotifier: User update completed successfully');
      // The auth state will be updated via the stream listener
      // but we can manually update it here for immediate feedback
      state = AuthState.authenticated(updatedUser);
    } catch (e) {
      print('AuthNotifier: User update error: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AuthState.loading();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      state = const AuthState.passwordResetSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    print('AuthNotifier: Starting password change');
    state = const AuthState.loading();
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      print('AuthNotifier: Password changed successfully');
      
      // Get current user to maintain the authenticated state
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        state = AuthState.authenticated(currentUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      print('AuthNotifier: Password change error: $e');
      state = AuthState.error(e.toString());
    }
  }

  void clearError() {
    if (state.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    )) {
      state = const AuthState.unauthenticated();
    }
  }
}

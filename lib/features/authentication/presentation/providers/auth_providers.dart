import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
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

// Current user provider
final currentUserProvider = StreamProvider<domain.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Auth state provider for UI
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
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
      (user) {
        print('Auth state changed: ${user?.email ?? 'null'}');
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
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
  }) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Don't set state manually - let the authStateChanges stream handle it
    } catch (e) {
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
      state = const AuthState.unauthenticated();
    } catch (e) {
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

  void clearError() {
    if (state.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    )) {
      state = const AuthState.unauthenticated();
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/auth_result.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  UserModel? get currentUser {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final user = _mapFirebaseUser(credential.user);
      if (user != null) {
        return AuthResult.success(user);
      } else {
        return const AuthResult.failure('Sign in failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }
      
      final user = _mapFirebaseUser(_firebaseAuth.currentUser);
      if (user != null) {
        return AuthResult.success(user);
      } else {
        return const AuthResult.failure('Sign up failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success(
        UserModel(uid: '', email: ''), // Placeholder for success result
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        return const AuthResult.success(
          UserModel(uid: '', email: ''), // Placeholder for success result
        );
      } else {
        return const AuthResult.failure('No user signed in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
        await user.reload();
        
        final updatedUser = _mapFirebaseUser(_firebaseAuth.currentUser);
        if (updatedUser != null) {
          return AuthResult.success(updatedUser);
        } else {
          return const AuthResult.failure('Update failed');
        }
      } else {
        return const AuthResult.failure('No user signed in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  UserModel? _mapFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
      lastSignInTime: firebaseUser.metadata.lastSignInTime,
    );
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

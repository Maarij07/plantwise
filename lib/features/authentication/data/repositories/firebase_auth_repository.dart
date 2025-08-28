import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUserToDomain);
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    return _mapFirebaseUserToDomain(_firebaseAuth.currentUser);
  }

  @override
  Future<domain.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      return _mapFirebaseUserToDomain(credential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<domain.User> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name if provided
      if (name.isNotEmpty && credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
      }
      
      final user = _mapFirebaseUserToDomain(_firebaseAuth.currentUser);
      if (user != null) {
        return user;
      } else {
        throw Exception('Sign up failed');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<domain.User> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.uid != userId) {
        throw Exception('User ID mismatch');
      }

      // Update display name
      if (name != null && name.isNotEmpty && user.displayName != name.trim()) {
        await user.updateDisplayName(name.trim());
      }

      // Update email
      if (email != null && email.isNotEmpty && user.email != email.trim()) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }

      // Update photo URL
      if (photoUrl != null && user.photoURL != photoUrl) {
        await user.updatePhotoURL(photoUrl);
      }

      // Reload user to get fresh data
      await user.reload();
      
      final updatedUser = _mapFirebaseUserToDomain(_firebaseAuth.currentUser);
      if (updatedUser != null) {
        return updatedUser;
      } else {
        throw Exception('Failed to update user');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.email == null) {
        throw Exception('User email is required for password change');
      }

      // Re-authenticate the user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update to new password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }



  domain.User? _mapFirebaseUserToDomain(User? firebaseUser) {
    if (firebaseUser == null) return null;
    
    return domain.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  String _getErrorMessage(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    
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
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'timeout':
        return 'Request timed out. Please check your internet connection and try again.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'permission-denied':
        return 'Permission denied. Please check your Firebase configuration.';
      case 'invalid-api-key':
        return 'Invalid API key. Please contact support.';
      case 'app-not-authorized':
        return 'App not authorized. Please contact support.';
      default:
        // Handle other network-related errors
        final message = e.message?.toLowerCase() ?? '';
        if (message.contains('network') || message.contains('connection') || 
            message.contains('timeout') || message.contains('dns')) {
          return 'Network error. Please check your internet connection and try again.';
        }
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

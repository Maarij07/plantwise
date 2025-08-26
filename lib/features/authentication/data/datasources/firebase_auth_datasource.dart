import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  
  Future<UserModel> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  });
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail({required String email});
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<UserModel?> getCurrentUser();
  
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Try to update last login time (ignore if Firestore fails)
        try {
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()});
        } catch (firestoreError) {
          print('Failed to update last login: $firestoreError');
        }

        // Try to get user from Firestore
        final firestoreUser = await _getUserFromFirestore(credential.user!.uid);
        if (firestoreUser != null) {
          return firestoreUser;
        }
        
        // If Firestore fails, create user from Firebase Auth data
        return UserModel(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? email,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      throw Exception('Network error. Please check your internet connection and try again.');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user document in Firestore (handle errors gracefully)
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        photoUrl: credential.user!.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      try {
        await _firestore.collection('users').doc(user.id).set(user.toJson());
        print('User document created successfully');
      } catch (firestoreError) {
        // Log Firestore error but don't fail the signup
        print('Failed to create user document: $firestoreError');
        // User account is still created successfully in Firebase Auth
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('Unexpected error during sign-up: $e');
      throw Exception('Network error. Please check your internet connection and try again.');
    }
  }

  @override
  Future<UserModel> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      print('Starting profile update for user: $userId');
      print('Update data - name: $name, email: $email, photoUrl: $photoUrl');
      
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        throw Exception('User not authenticated');
      }
      
      if (currentUser.uid != userId) {
        print('User ID mismatch: ${currentUser.uid} vs $userId');
        throw Exception('User ID mismatch');
      }

      // Get current user data from Firestore
      print('Getting current user data from Firestore...');
      final currentUserData = await _getUserFromFirestore(userId);
      if (currentUserData == null) {
        print('User data not found in Firestore');
        throw Exception('User data not found');
      }
      print('Current user data loaded: ${currentUserData.name}, ${currentUserData.email}');

      // For now, skip Firebase Auth updates and only update Firestore
      // TODO: Re-enable Firebase Auth updates after testing
      print('Skipping Firebase Auth profile updates for now...');
      
      // Create updated user model
      final updatedUser = UserModel(
        id: userId,
        name: name ?? currentUserData.name,
        email: email ?? currentUserData.email,
        photoUrl: photoUrl ?? currentUserData.photoUrl,
        createdAt: currentUserData.createdAt,
        lastLoginAt: currentUserData.lastLoginAt,
      );
      print('Created updated user model: ${updatedUser.name}, ${updatedUser.email}');

      // Update Firestore document
      print('Updating Firestore document...');
      final updateData = {
        'name': updatedUser.name,
        'email': updatedUser.email,
        'photoUrl': updatedUser.photoUrl,
      };
      print('Update data: $updateData');
      
      await _firestore.collection('users').doc(userId).update(updateData);
      print('Firestore update completed successfully');

      print('User profile updated successfully');
      return updatedUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth error during update: ${e.code} - ${e.message}');
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('Unexpected error during profile update: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('Unexpected error during sign-out: $e');
      throw Exception('Network error occurred during sign-out.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      // First check if user exists by trying to fetch sign-in methods
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      
      if (signInMethods.isEmpty) {
        // User doesn't exist - throw custom error
        throw Exception('No account found with this email address. Please check your email or sign up for a new account.');
      }
      
      // User exists, send password reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      
      print('Password reset email sent to: $email');
      print('User sign-in methods: $signInMethods');
      
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email address. Please check your email or sign up for a new account.');
      }
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (currentUser.email == null) {
        throw Exception('User email not available');
      }

      print('Starting password change for user: ${currentUser.email}');
      
      // Create credential with current password to re-authenticate
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      
      print('Re-authenticating user...');
      // Re-authenticate the user with their current password
      await currentUser.reauthenticateWithCredential(credential);
      print('Re-authentication successful');
      
      // Update password
      print('Updating password...');
      await currentUser.updatePassword(newPassword);
      print('Password updated successfully');
      
      // Optionally update password change timestamp in Firestore
      try {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({'passwordChangedAt': FieldValue.serverTimestamp()});
        print('Password change timestamp updated in Firestore');
      } catch (firestoreError) {
        print('Failed to update password change timestamp: $firestoreError');
        // Don't fail the entire operation if Firestore update fails
      }
      
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth error during password change: ${e.code} - ${e.message}');
      throw Exception(_handlePasswordChangeException(e));
    } catch (e) {
      print('Unexpected error during password change: $e');
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      print('Firebase auth state changed: ${firebaseUser?.email ?? 'null'}');
      if (firebaseUser == null) return null;
      
      // Create user directly from Firebase Auth data (no async Firestore calls)
      return UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    });
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        
        // Handle Firestore Timestamp objects
        final Map<String, dynamic> cleanData = {
          'id': data['id'] ?? uid,
          'name': data['name'] ?? 'User',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'],
        };
        
        // Handle createdAt field
        if (data['createdAt'] is Timestamp) {
          cleanData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        } else if (data['createdAt'] is String) {
          cleanData['createdAt'] = data['createdAt'];
        } else {
          cleanData['createdAt'] = DateTime.now().toIso8601String();
        }
        
        // Handle lastLoginAt field
        if (data['lastLoginAt'] is Timestamp) {
          cleanData['lastLoginAt'] = (data['lastLoginAt'] as Timestamp).toDate().toIso8601String();
        } else if (data['lastLoginAt'] is String) {
          cleanData['lastLoginAt'] = data['lastLoginAt'];
        } else {
          cleanData['lastLoginAt'] = null;
        }
        
        return UserModel.fromJson(cleanData);
      }
      return null;
    } catch (e) {
      print('Error getting user from Firestore: $e');
      return null;
    }
  }

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
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

  String _handlePasswordChangeException(firebase_auth.FirebaseAuthException e) {
    print('Firebase Auth Password Change Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'wrong-password':
        return 'Current password is incorrect. Please try again.';
      case 'weak-password':
        return 'New password is too weak. Please use a stronger password with uppercase, lowercase, numbers, and special characters.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign out and sign in again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'User account not found.';
      case 'invalid-credential':
        return 'Current password is incorrect. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'timeout':
        return 'Request timed out. Please check your internet connection and try again.';
      default:
        final message = e.message?.toLowerCase() ?? '';
        if (message.contains('network') || message.contains('connection') || 
            message.contains('timeout') || message.contains('dns')) {
          return 'Network error. Please check your internet connection and try again.';
        }
        return e.message ?? 'Failed to change password. Please try again.';
    }
  }
}

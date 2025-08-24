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
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail({required String email});
  
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
      throw _handleAuthException(e);
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
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
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
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
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
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

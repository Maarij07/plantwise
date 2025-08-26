import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<User> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  
  Future<User> updateUser({
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
  
  Future<User?> getCurrentUser();
  
  Stream<User?> get authStateChanges;
}

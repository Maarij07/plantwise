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
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail({required String email});
  
  Future<User?> getCurrentUser();
  
  Stream<User?> get authStateChanges;
}

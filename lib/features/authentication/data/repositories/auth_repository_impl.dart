import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl({
    required AuthDataSource authDataSource,
  }) : _authDataSource = authDataSource;

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('AuthRepositoryImpl: Starting sign-in for $email');
    final userModel = await _authDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('AuthRepositoryImpl: Received user model: ${userModel?.toEntity().name}');
    return userModel?.toEntity();
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final userModel = await _authDataSource.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<User> updateUser({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    print('AuthRepositoryImpl: Starting user update for $userId');
    final userModel = await _authDataSource.updateUser(
      userId: userId,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
    print('AuthRepositoryImpl: User update completed successfully');
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _authDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    print('AuthRepositoryImpl: Starting password change');
    await _authDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    print('AuthRepositoryImpl: Password change completed successfully');
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await _authDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<User?> get authStateChanges {
    return _authDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }
}

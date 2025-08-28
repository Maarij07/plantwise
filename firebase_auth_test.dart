import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase initialized successfully');

  try {
    // Test authentication
    final auth = FirebaseAuth.instance;
    print('Current user: ${auth.currentUser?.email ?? 'null'}');

    // Test sign in with existing user
    print('Testing sign in with taha69@gmail.com...');
    
    final credential = await auth.signInWithEmailAndPassword(
      email: 'taha69@gmail.com',
      password: 'TestPassword123',
    );
    
    print('Sign in successful! User: ${credential.user?.email}');
    print('User UID: ${credential.user?.uid}');
    print('User display name: ${credential.user?.displayName}');
    
  } catch (e) {
    print('Authentication error: $e');
  }

  // Test sign out
  try {
    await FirebaseAuth.instance.signOut();
    print('Sign out successful');
  } catch (e) {
    print('Sign out error: $e');
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Router notifier that listens to Firebase auth state changes
/// and notifies the router when authentication state changes
class RouterNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authStateSubscription;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  RouterNotifier(this._firebaseAuth) {
    // Listen to Firebase auth state changes
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((User? user) {
      print('RouterNotifier: Auth state changed, user: ${user?.email ?? 'null'}');
      final wasAuthenticated = _isAuthenticated;
      _isAuthenticated = user != null;
      
      // Only notify listeners if authentication state actually changed
      if (wasAuthenticated != _isAuthenticated) {
        print('RouterNotifier: Authentication state changed from $wasAuthenticated to $_isAuthenticated');
        notifyListeners();
      }
    });
    
    // Set initial state
    _isAuthenticated = _firebaseAuth.currentUser != null;
    print('RouterNotifier: Initial auth state: $_isAuthenticated');
  }
  
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(FirebaseAuth.instance);
});

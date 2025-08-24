import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _rememberMeKey = 'remember_me';

  static AuthStorageService? _instance;
  static AuthStorageService get instance => _instance ??= AuthStorageService._();
  
  AuthStorageService._();

  // Save login state with Remember Me support
  Future<void> saveLoginState({
    required bool isLoggedIn,
    bool rememberMe = true, // Default to true for backward compatibility
    String? userId,
    String? email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Only save persistent login state if rememberMe is true
    if (rememberMe) {
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
      await prefs.setBool(_rememberMeKey, true);
      
      if (isLoggedIn) {
        if (userId != null) await prefs.setString(_userIdKey, userId);
        if (email != null) await prefs.setString(_userEmailKey, email);
        if (name != null) await prefs.setString(_userNameKey, name);
      }
    } else {
      // If Remember Me is false, clear any existing persistent state
      // but don't store new login state for persistence
      await prefs.setBool(_rememberMeKey, false);
      await clearLoginState();
    }
  }

  // Get login state
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get stored user data
  Future<Map<String, String?>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
    };
  }

  // Clear login state (for logout)
  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }

  // Check if it's the first app launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  // Mark that the user has completed onboarding
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Remember Me specific methods
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> setRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  // Enhanced login check that considers Remember Me preference
  Future<bool> shouldPersistLogin() async {
    final isLoggedIn = await this.isLoggedIn();
    final rememberMe = await isRememberMeEnabled();
    return isLoggedIn && rememberMe;
  }

  // Clear all stored data (for complete reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

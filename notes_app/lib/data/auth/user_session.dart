import 'package:shared_preferences/shared_preferences.dart';

class UserSessionManager {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';
  static const String _userUidKey = 'user_uid';

  // Save user session
  static Future<void> saveUserSession({
    required String email,
    String? username,
    String? userId,
    String? userUid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    if (username != null) await prefs.setString(_usernameKey, username);
    if (userId != null) await prefs.setString(_userIdKey, userId);
    if (userUid != null) await prefs.setString(_userUidKey, userUid);
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Get username
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Clear user session (logout)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears all stored data
  }
}

import 'package:flutter/material.dart';
import 'package:notes_app/data/auth/user_session.dart';

class AuthController with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _userEmail;
  String? _username;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userEmail => _userEmail;
  String? get username => _username;

  // Initialize auth state on app start
  Future<void> initializeAuthState() async {
    try {
      _isLoading = true;
      // Don't notify listeners immediately during initialization

      _isLoggedIn = await UserSessionManager.isUserLoggedIn();
      if (_isLoggedIn) {
        _userEmail = await UserSessionManager.getUserEmail();
        _username = await UserSessionManager.getUsername();
      }
    } catch (e) {
      _isLoggedIn = false;
      debugPrint('Error initializing auth state: $e');
    } finally {
      _isLoading = false;
      // Only notify listeners once at the end
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Login user
  Future<void> loginUser({
    required String email,
    String? username,
    String? userId,
    String? userUid,
  }) async {
    await UserSessionManager.saveUserSession(
      email: email,
      username: username,
      userId: userId,
      userUid: userUid,
    );
    _isLoggedIn = true;
    _userEmail = email;
    _username = username;

    // Use post frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Logout user
  Future<void> logoutUser() async {
    await UserSessionManager.clearUserSession();
    _isLoggedIn = false;
    _userEmail = null;
    _username = null;

    // Use post frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}

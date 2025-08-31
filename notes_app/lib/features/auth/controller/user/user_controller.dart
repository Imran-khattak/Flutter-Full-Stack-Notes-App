import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/data/auth/user_session.dart';
import 'package:notes_app/data/repositories/network_repositories.dart';
import 'package:notes_app/features/auth/controller/auth_session.dart';
import 'package:notes_app/features/models/user_model.dart';
import 'package:notes_app/utils/popus/loaders.dart';
import 'package:provider/provider.dart';

import '../../view/sign_in_screen.dart';

class UserController with ChangeNotifier {
  bool _isLoading = false;
  bool _hasProfileChanges = false;
  String _originalName = '';
  String _originalEmail = '';

  final TextEditingController name = TextEditingController();
  final updateNamekey = GlobalKey<FormState>();
  final FocusNode nameFocus = FocusNode();

  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get hasProfileChanges => _hasProfileChanges;
  UserModel? get user => _user;

  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setProfileChanges(bool value) {
    _hasProfileChanges = value;
    notifyListeners();
  }

  UserController() {
    fetchUser();
    // Listen for changes in name controller
    name.addListener(checkForChanges);
  }

  // Initialize profile with current user data
  void initializeProfile(UserModel user) {
    _originalName = user.username ?? '';
    _originalEmail = user.email ?? '';
    name.text = _originalName;
    _hasProfileChanges = false;
    notifyListeners();
  }

  // Check for changes in profile data
  void checkForChanges() {
    bool hasChanges = name.text.trim() != _originalName.trim();

    if (hasChanges != _hasProfileChanges) {
      _setProfileChanges(hasChanges);
    }
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Show snackbar helper
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? const Color(0xFF48BB78)
            : const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool hasChanges(TextEditingController newtext) {
    return name.text != newtext.text;
  }

  Future<void> fetchUser() async {
    try {
      _setLoading(true);
      final netRepo = NetworkRepositories();
      final userId = await UserSessionManager.getUserId();

      final userInfo = await netRepo.getUser(userId!);
      _user = userInfo;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      throw "Something went wrong while fetching user";
    }
  }

  Future<void> updateProfile(BuildContext context, [String? email]) async {
    try {
      _setLoading(true);

      if (!updateNamekey.currentState!.validate()) {
        _setLoading(false);
        return;
      }

      if (!_hasProfileChanges) {
        _showSnackBar(context, 'No changes to update');
        _setLoading(false);
        return;
      }

      final netRepo = NetworkRepositories();

      // Include the uid from the current user
      final updateUser = UserModel(
        uid: _user?.uid ?? _user?.id, // Use uid or fallback to id
        username: name.text.trim(),
        email: email ?? _originalEmail,
      );

      // Remove the delay - this was just for simulation
      // await Future.delayed(const Duration(seconds: 2));

      final updatedUser = await netRepo.updateProfile(updateUser);

      // Update local user data with the response from server
      _user = updatedUser;

      // Update original values
      _originalName = name.text.trim();
      if (email != null) {
        _originalEmail = email;
      }

      _setProfileChanges(false);

      TLoaders.successSnackBar(
        context: context,
        title: "Update!",
        message: 'Profile updated successfully',
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, {
          'name': name.text.trim(),
          'email': email ?? _originalEmail,
        });
      });
    } catch (e) {
      TLoaders.errorSnackBar(
        context: context,
        title: 'Oh Snap!',
        message: 'Failed to update profile. Please try again.',
      );
      debugPrint("Failed profile update: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Reset profile changes
  void resetProfileChanges() {
    name.text = _originalName;
    _setProfileChanges(false);
  }

  // Clear profile data (useful when logging out)
  void clearProfileData() {
    name.clear();
    _originalName = '';
    _originalEmail = '';
    _setProfileChanges(false);
    _user = null;
  }

  Future<void> logout(BuildContext context) async {
    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      await authController.logoutUser();

      // Navigate first, then clear data
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (route) => false,
      );

      // Clear profile data after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        clearProfileData();
      });
    } catch (e) {
      TLoaders.errorSnackBar(
        context: context,
        title: "Oh Snap!",
        message: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    name.removeListener(checkForChanges);
    name.dispose();
    nameFocus.dispose();
    super.dispose();
  }
}

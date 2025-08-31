import 'package:flutter/material.dart';
import 'package:notes_app/data/repositories/network_repositories.dart';
import 'package:notes_app/features/auth/controller/auth_session.dart';
import 'package:notes_app/features/models/user_model.dart';
import 'package:notes_app/features/view/home_screen.dart';
import 'package:notes_app/utils/images.dart';
import 'package:notes_app/utils/popus/full_screen_loader.dart';
import 'package:notes_app/utils/popus/loaders.dart';
import 'package:provider/provider.dart';

class SignUpController with ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool _ishidePassword = true;
  bool _isLoading = false;

  bool get ishidePassword => _ishidePassword;
  bool get isLoading => _isLoading;

  void togglePassword() {
    _ishidePassword = !_ishidePassword;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Signup....
  Future<void> signUp(BuildContext context) async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Set loading state
      _setLoading(true);

      // Show loading dialog
      TFullScreenLoader.openLoadingDialog(
        context,
        "Processing your information",
        TImages.docerAnimation,
      );

      final userRepo = NetworkRepositories();

      final newUser = UserModel(
        id: '',
        username: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        uid: '',
      );

      // Sign up the user - this should return the created user with proper ID
      final createdUser = await userRepo.signUp(newUser);

      // Save simple session - just store that user is logged in
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      await authController.loginUser(
        email: emailController.text.trim(),
        userId: createdUser.id,
        username: '', // You can get this from API response if available
      );

      _setLoading(false);
      TFullScreenLoader.stopLoading();

      clearFields();

      TLoaders.successSnackBar(
        context: context,
        title: "Congratulations! Your account was successfully created",
      );

      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesHomeScreen()),
      );
    } on ServerExceptions catch (e) {
      // Stop loading
      _setLoading(false);
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
      // Show error message
      TLoaders.errorSnackBar(
        context: context,
        title: "Oh Snap!",
        message: e.toString(),
      );

      print('SignUp Error: ${e.errorMessage}');
    } catch (e) {
      // Stop loading
      _setLoading(false);
      TFullScreenLoader.stopLoading();
      Navigator.pop(context);
      // Show error message
      TLoaders.errorSnackBar(
        context: context,
        title: "Oh Snap!",
        message: e.toString(),
      );

      // Print error for debugging
      debugPrint("SignUp Error: $e");
    }
  }

  void clearFields() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();

    // Also unfocus all fields
    fullNameFocus.unfocus();
    emailFocus.unfocus();
    passwordFocus.unfocus();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }
}

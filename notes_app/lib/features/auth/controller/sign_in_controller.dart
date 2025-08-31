import 'package:flutter/material.dart';
import 'package:notes_app/data/repositories/network_repositories.dart';
import 'package:notes_app/features/auth/controller/auth_session.dart';
import 'package:notes_app/features/models/user_model.dart';
import 'package:notes_app/features/view/home_screen.dart';
import 'package:notes_app/utils/images.dart';
import 'package:notes_app/utils/popus/full_screen_loader.dart';
import 'package:notes_app/utils/popus/loaders.dart';
import 'package:provider/provider.dart';

class SignInController with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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

  Future<void> signIn(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      _setLoading(true);

      TFullScreenLoader.openLoadingDialog(
        context,
        "Logging you in...",
        TImages.docerAnimation,
      );

      final userRepo = NetworkRepositories();

      final loginUser = UserModel(
        id: '',
        username: '',
        email: emailController.text.trim(),
        password: passwordController.text,
        uid: '',
      );

      final currentUser = await userRepo.signIn(loginUser);

      // Save simple session - just store that user is logged in
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );

      await authController.loginUser(
        email: emailController.text.trim(),
        userId: currentUser.id,
        username: '', // You can get this from API response if available
      );

      _setLoading(false);
      TFullScreenLoader.stopLoading();

      clearFields();

      TLoaders.successSnackBar(context: context, title: "Welcome back!");
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

      print('SignIn Error: ${e.errorMessage}');
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
      debugPrint("SignIn Error: $e");
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();

    emailFocus.unfocus();
    passwordFocus.unfocus();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }
}

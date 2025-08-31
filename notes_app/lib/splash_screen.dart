// 4. Create a SplashScreen to check auth status
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_app/data/auth/user_session.dart';
import 'package:notes_app/features/auth/controller/auth_session.dart';
import 'package:provider/provider.dart';

import 'package:notes_app/features/auth/view/sign_in_screen.dart';
import 'package:notes_app/features/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final userId = await UserSessionManager.getUserId();

    debugPrint("current user id in splash screen : $userId");
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.initializeAuthState();

    if (!mounted) return;

    // Navigate based on auth status
    if (authController.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo or icon here
            Icon(Iconsax.note, size: 80, color: Color(0xFF2D3748)),
            SizedBox(height: 24),
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
            ),
          ],
        ),
      ),
    );
  }
}

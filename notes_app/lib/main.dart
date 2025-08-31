import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/features/auth/controller/auth_session.dart';
import 'package:notes_app/features/auth/controller/sign_in_controller.dart';
import 'package:notes_app/features/auth/controller/sign_up_controller.dart';
import 'package:notes_app/features/auth/controller/user/user_controller.dart';
import 'package:notes_app/features/notes/controller/notes_controller.dart';

import 'package:notes_app/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SignUpController()),
        ChangeNotifierProvider(create: (_) => SignInController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
      ],
      child: MaterialApp(
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          fontFamily: 'SF Pro Display',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF2D3748),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 8,
            backgroundColor: Color(0xFFFFF3E0),
          ),
        ),

        home: const SplashScreen(), // Start with SplashScreen
      ),
    );
  }
}

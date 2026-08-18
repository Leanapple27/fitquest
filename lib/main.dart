import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/student_home_screen.dart';
import 'screens/welcome_screen.dart';
import 'notification_service.dart';
import 'theme/theme.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await NotificationService.requestPermission();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ThemeController.instance.load();

  final prefs = await SharedPreferences.getInstance();
  final bool alwaysLogin = prefs.getBool('always_login') ?? true;
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null && alwaysLogin;

  runApp(FitQuestApp(isLoggedIn: isLoggedIn));
}

class FitQuestApp extends StatelessWidget {
  final bool isLoggedIn;
  const FitQuestApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FitQuest',
          themeMode: ThemeController.instance.themeMode,
          theme: FqTheme.light,
          darkTheme: FqTheme.dark,
          home: isLoggedIn ? const StudentHomeScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}

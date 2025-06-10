import 'package:flutter/material.dart';
import 'package:to_do_list_app/main.dart';

import 'package:to_do_list_app/screens/auth/forgot_password_page.dart';
import 'package:to_do_list_app/screens/auth/login_page.dart';
import 'package:to_do_list_app/screens/auth/otp_verification_screen.dart';
import 'package:to_do_list_app/screens/auth/register_page.dart';
import 'package:to_do_list_app/screens/auth/reset_password_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/otp-verification': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return OtpVerificationScreen(email: email);
        },
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Trang Login


// Trang Register


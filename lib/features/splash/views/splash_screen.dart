import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/local_storage_service.dart'; // Ensure this points to your new service

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // 1. Wait for 3 seconds, just like your original code
    await Future.delayed(const Duration(seconds: 3));

    // 2. Check Local Storage for saved user data (replacing Firebase AuthGate)
    final String? userData = await LocalStorageService().getUserData();

    if (mounted) {
      // 3. Route directly to Dashboard if logged in, otherwise to Login
      if (userData != null && userData.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches the edges of your image
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/splash_image.jpeg',
          fit: BoxFit.cover, // This ensures the image covers the whole screen
        ),
      ),
    );
  }
}
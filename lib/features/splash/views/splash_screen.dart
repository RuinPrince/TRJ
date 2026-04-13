import 'dart:async';
import 'package:flutter/material.dart';
import '../../../main.dart'; // Adjust this path if your main.dart is located differently

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Wait for 3 seconds, then transition to AuthGate
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
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
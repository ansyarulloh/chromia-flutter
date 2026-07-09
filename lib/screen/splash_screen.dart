import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Langsung cek status login pas app dibuka
    checkAuth();
  }

  void checkAuth() async {
    // Kasih delay 2 detik biar logo lu sempat kelihatan (branding)
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (!mounted) return;

    if (token != null) {
      // Udah login? Gas ke MainScreen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } else {
      // Belum? Tetap di LoginScreen (atau stay di Splash kalau mau ada tombol 'Get Started')
      // Kalau lu mau tetep ada tombol "Get Started", panggil LoginScreen lewat tombol di bawah.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.remove_red_eye, color: AppColors.primary, size: 80),
            const SizedBox(height: 16),
            const Text('Chromia', style: TextStyle(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const Text('AI Color Detection', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            
            // Tombol ini tetep ada buat user baru yang mau baca onboarding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.dark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
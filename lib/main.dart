import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'screen/splash_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const ChromiaApp());
}

class ChromiaApp extends StatelessWidget {
  const ChromiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chromia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // Biar UI lebih modern & clean
        scaffoldBackgroundColor: AppColors.background,
        // Font Poppins bikin aplikasi berasa pro dan modern
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
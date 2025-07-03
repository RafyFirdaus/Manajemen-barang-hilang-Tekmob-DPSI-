import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Simulate loading time and navigate to login screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              // Welcome Image
              SvgPicture.asset(
                'lib/src/assets/images/welcome image.svg',
                height: 300,
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Manajemen\nBarang Hilang',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F41BB),
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Bantu Temukan, Bantu Kembalikan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Loading indicator instead of buttons
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // Loading indicator
                    const CircularProgressIndicator(
                      color: Color(0xFF1F41BB),
                      strokeWidth: 5,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Buttons (disabled but kept for reference)
              // Visibility set to false to hide them
              Visibility(
                visible: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Button
                    CustomButton(
                      text: 'Login',
                      isActive: false, // disabled
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    // Register Button
                    CustomButton(
                      text: 'Register',
                      isActive: false, // disabled
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _agreeToTerms = false;
  
  // Controllers for form fields
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  
  // Focus nodes to track field focus state
  final _namaFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _teleponFocus = FocusNode();
  final _alamatFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes
    _namaFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
    _teleponFocus.addListener(_onFocusChange);
    _alamatFocus.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    // Dispose controllers
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    
    // Dispose focus nodes
    _namaFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _teleponFocus.dispose();
    _alamatFocus.dispose();
    
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      // This will trigger a rebuild when focus changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Login link
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Title
                Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F41BB),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Form fields
                // Nama Lengkap
                _buildTextField(
                  controller: _namaController,
                  focusNode: _namaFocus,
                  hintText: 'Nama Lengkap',
                ),
                const SizedBox(height: 16),
                
                // Email
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Password
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hintText: 'Password',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  hintText: 'Confirm Password',
                  obscureText: _obscureConfirmText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmText = !_obscureConfirmText;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nomor Telepon
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocus,
                  hintText: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Alamat Domisili
                _buildTextField(
                  controller: _alamatController,
                  focusNode: _alamatFocus,
                  hintText: 'Alamat Domisili',
                ),
                const SizedBox(height: 16),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: const Color(0xFF1F41BB),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Saya menyetujui Syarat dan Ketentuan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Register button
                CustomButton(
                  text: 'Daftar',
                  isActive: true,
                  onPressed: () {
                    // Implement registration logic
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final bool isFocused = focusNode.hasFocus;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? const Color(0xFF1F41BB) : Colors.grey.shade300,
          width: isFocused ? 2.0 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
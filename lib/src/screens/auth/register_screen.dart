import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  
  // Error messages
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _teleponError;
  String? _registerError;
  
  // Controllers for form fields
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  
  // Image picker removed - no longer needed
  
  // Focus nodes to track field focus state
  final _namaFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _teleponFocus = FocusNode();
  final _alamatFocus = FocusNode();
  
  // Auth service
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes
    _namaFocus.addListener(_onFocusChange);
    _usernameFocus.addListener(_onFocusChange);
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    
    // Dispose focus nodes
    _namaFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _teleponFocus.dispose();
    _alamatFocus.dispose();
    
    super.dispose();
  }
  
  // Image picker methods removed - no longer needed
  
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                const SizedBox(height: 40),
                
                // Form fields
                // Username
                _buildTextField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  hintText: 'Nama Lengkap',
                  errorText: _usernameError,
                ),
                const SizedBox(height: 16),
                
                // Email
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                
                // Password
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hintText: 'Password',
                  obscureText: _obscureText,
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                  obscureText: true,
                  errorText: _confirmPasswordError,
                ),
                const SizedBox(height: 20),
                
                // Nomor Telepon
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocus,
                  hintText: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                  errorText: _teleponError,
                ),
                const SizedBox(height: 20),
                
                // Foto Identitas field removed
                
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
                const SizedBox(height: 30),
                
                // Error message
                if (_registerError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _registerError!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Register button
                CustomButton(
                  text: _isLoading ? 'Mendaftar...' : 'Daftar',
                  isActive: _agreeToTerms && !_isLoading,
                  onPressed: () {
                    if (_agreeToTerms && !_isLoading) {
                      _handleRegister();
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Handle registration
  Future<void> _handleRegister() async {
    // Reset errors
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _teleponError = null;
      _registerError = null;
      _isLoading = true;
    });
    
    // Validate inputs
    bool isValid = true;
    
    // Username validation
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Nama lengkap tidak boleh kosong';

      });
      isValid = false;
    } else if (username.length < 3) {
      setState(() {
        _usernameError = 'Nama lengkap minimal 3 karakter';
      });
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Nama lengkap hanya boleh mengandung huruf, angka, dan underscore';
      });
      isValid = false;
    }
    
    // Email validation
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email tidak boleh kosong';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Format email tidak valid';
      });
      isValid = false;
    }
    
    // Password validation
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password tidak boleh kosong';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password minimal 6 karakter';
      });
      isValid = false;
    }
    
    // Confirm password validation
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
      });
      isValid = false;
    } else if (confirmPassword != password) {
      setState(() {
        _confirmPasswordError = 'Password tidak cocok';
      });
      isValid = false;
    }
    
    // Phone validation
    final phone = _teleponController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _teleponError = 'Nomor telepon tidak boleh kosong';
      });
      isValid = false;
    } else if (!RegExp(r'^[0-9]{10,13}$').hasMatch(phone)) {
      setState(() {
        _teleponError = 'Format nomor telepon tidak valid';
      });
      isValid = false;
    }
    
    // Terms validation
    if (!_agreeToTerms) {
      setState(() {
        _registerError = 'Anda harus menyetujui syarat dan ketentuan';
      });
      isValid = false;
    }
    
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Call auth service
    try {
      final result = await _authService.register(
        name: username, // Menggunakan username sebagai nama
        username: username,
        email: email,
        password: password,
        phone: phone,
        address: _alamatController.text.trim(),
        fotoIdentitasPath: null, // No photo upload during registration
      );
      
      if (result['success']) {
        // Registration successful - navigate to login or home
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          // Navigate back to login
          Navigator.pop(context);
        }
      } else {
        // Registration failed
        if (mounted) {
          setState(() {
            _registerError = result['message'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _registerError = 'Terjadi kesalahan: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError 
                ? Colors.red 
                : (isFocused ? const Color(0xFF1F41BB) : Colors.grey.shade300),
              width: isFocused || hasError ? 2.0 : 1.0,
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
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 12.0),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
  
  // _buildImagePicker function removed - no longer needed

}
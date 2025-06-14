import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _loginError;
  
  // Controllers for form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Focus nodes to track field focus state
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  // Auth service
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    
    // Dispose focus nodes
    _emailFocus.dispose();
    _passwordFocus.dispose();
    
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              // Title
              Text(
                'Masuk di sini',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F41BB),
                ),
              ),
              const SizedBox(height: 30),
              // Welcome message
              Text(
                'Selamat Datang,\nSenang melihatmu kembali!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 60),
              // Email field
              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),
              // Password field
              _buildTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hintText: 'Kata Sandi',
                obscureText: _obscureText,
                errorText: _passwordError,
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
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lupa kata sandi Anda?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1F41BB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Error message
              if (_loginError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _loginError!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F41BB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFFCBD7FF),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              // Create account
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Buat akun baru',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Or login with
              Text(
                'Atau masuk dengan:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialLoginButton('Google', Icons.g_mobiledata),
                  const SizedBox(width: 16),
                  _socialLoginButton('Facebook', Icons.facebook),
                  const SizedBox(width: 16),
                  _socialLoginButton('Apple', Icons.apple),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
  
  // Handle login
  Future<void> _handleLogin() async {
    // Reset errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _loginError = null;
      _isLoading = true;
    });
    
    // Validate inputs
    bool isValid = true;
    
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
    
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Call auth service
    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        // Login successful - navigate to home or dashboard
        if (mounted) {
          // TODO: Navigate to home/dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        // Login failed
        if (mounted) {
          setState(() {
            _loginError = result['message'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Terjadi kesalahan: $e';
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
  }

  Widget _socialLoginButton(String platform, IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () {},
      ),
    );
  }

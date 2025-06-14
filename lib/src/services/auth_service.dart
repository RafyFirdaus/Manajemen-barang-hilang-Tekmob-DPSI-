import 'dart:async';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Dummy login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Dummy validation
    if (email.isEmpty || !email.contains('@')) {
      return {
        'success': false,
        'message': 'Email tidak valid',
      };
    }
    
    if (password.isEmpty || password.length < 6) {
      return {
        'success': false,
        'message': 'Password harus minimal 6 karakter',
      };
    }
    
    // Simulate successful login for test account
    if (email == 'test@example.com' && password == 'password123') {
      return {
        'success': true,
        'message': 'Login berhasil',
        'user': {
          'id': '1',
          'name': 'Test User',
          'email': email,
        },
      };
    }
    
    // Default: login failed
    return {
      'success': false,
      'message': 'Email atau password salah',
    };
  }

  // Dummy register method
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Dummy validation (actual validation should be done in UI)
    if (name.isEmpty) {
      return {
        'success': false,
        'message': 'Nama tidak boleh kosong',
      };
    }
    
    if (email.isEmpty || !email.contains('@')) {
      return {
        'success': false,
        'message': 'Email tidak valid',
      };
    }
    
    if (password.isEmpty || password.length < 6) {
      return {
        'success': false,
        'message': 'Password harus minimal 6 karakter',
      };
    }
    
    if (phone.isEmpty || phone.length < 10) {
      return {
        'success': false,
        'message': 'Nomor telepon tidak valid',
      };
    }
    
    // Simulate successful registration
    return {
      'success': true,
      'message': 'Registrasi berhasil',
      'user': {
        'id': '2',
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      },
    };
  }
}
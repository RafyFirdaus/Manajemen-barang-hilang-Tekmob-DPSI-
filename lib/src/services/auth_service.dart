import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Base URL untuk API backend
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  
  // Secure storage untuk menyimpan token
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Login method dengan integrasi API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Validasi input
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

      // Kirim request ke API backend
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login berhasil
        final token = responseData['token'];
        final user = responseData['user'];
        
        // Simpan token ke secure storage
        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'user_id', value: user['id']);
        await _secureStorage.write(key: 'user_email', value: user['email']);
        await _secureStorage.write(key: 'user_username', value: user['username']);
        await _secureStorage.write(key: 'user_role', value: user['role']);
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login berhasil',
          'user': {
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'role': user['role'],
          },
        };
      } else {
        // Login gagal
        return {
          'success': false,
          'message': responseData['error'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      // Error handling
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Register method dengan integrasi API
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      // Validasi input
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

      // Kirim request ke API backend
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registrasi berhasil
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'user': {
            'id': data['user']['id'],
            'username': data['user']['username'],
            'email': data['user']['email'],
            'role': data['user']['role'],
          },
        };
      } else {
        // Registrasi gagal
        return {
          'success': false,
          'message': data['error'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      // Error handling
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Method untuk logout
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  // Method untuk mendapatkan token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Method untuk mendapatkan data user
  Future<Map<String, String?>> getUserData() async {
    return {
      'id': await _secureStorage.read(key: 'user_id'),
      'email': await _secureStorage.read(key: 'user_email'),
      'username': await _secureStorage.read(key: 'user_username'),
      'role': await _secureStorage.read(key: 'user_role'),
    };
  }

  // Method untuk cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Method untuk request dengan autentikasi
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
  }) async {
    final token = await getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      case 'PUT':
        return await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      case 'DELETE':
        return await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        );
      default:
        return await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        );
    }
  }
}
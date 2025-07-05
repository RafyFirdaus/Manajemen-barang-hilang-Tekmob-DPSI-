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
        await _secureStorage.write(key: 'user_phone', value: user['phone'] ?? '');
        await _secureStorage.write(key: 'user_url_foto_identitas', value: user['url_foto_identitas'] ?? '');
        
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
    required String username,
    required String email,
    required String password,
    required String phone,
    required String address,
    String? fotoIdentitasPath,
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

      // Buat multipart request untuk upload foto
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));
      
      // Tambahkan field data
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      
      // Tambahkan foto identitas jika ada
      if (fotoIdentitasPath != null && fotoIdentitasPath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath(
          'foto_identitas',
          fotoIdentitasPath,
        );
        request.files.add(file);
      }
      
      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
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
            'url_foto_identitas': data['user']['url_foto_identitas'] ?? '',
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
      'phone': await _secureStorage.read(key: 'user_phone'),
      'url_foto_identitas': await _secureStorage.read(key: 'user_url_foto_identitas'),
    };
  }

  // Method untuk mendapatkan data user lengkap
  Future<Map<String, String?>> getFullUserData() async {
    try {
      // Coba ambil dari secure storage dulu
      final localData = await getUserData();
      
      // Jika phone atau url_foto_identitas tidak ada di local storage, coba ambil dari API
      if ((localData['phone'] == null || localData['phone']!.isEmpty) ||
          (localData['url_foto_identitas'] == null || localData['url_foto_identitas']!.isEmpty)) {
        final userId = localData['id'];
        if (userId != null && userId.isNotEmpty) {
          final apiData = await getUserById(userId);
          if (apiData != null) {
            if (apiData['phone'] != null) {
              await _secureStorage.write(key: 'user_phone', value: apiData['phone']);
              localData['phone'] = apiData['phone'];
            }
            if (apiData['url_foto_identitas'] != null) {
              await _secureStorage.write(key: 'user_url_foto_identitas', value: apiData['url_foto_identitas']);
              localData['url_foto_identitas'] = apiData['url_foto_identitas'];
            }
          }
        }
      }
      
      return localData;
    } catch (e) {
      print('Error getting full user data: $e');
      return await getUserData();
    }
  }

  // Method untuk mendapatkan nomor telepon
  Future<String?> getPhoneNumber() async {
    return await _secureStorage.read(key: 'user_phone');
  }

  // Method untuk cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Method untuk mendapatkan data user berdasarkan ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await authenticatedRequest('/users/$userId');
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'id': userData['id'],
          'username': userData['username'],
          'email': userData['email'],
          'role': userData['role'],
          'url_foto_identitas': userData['url_foto_identitas'] ?? '',
        };
      } else {
        print('Error getting user by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
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
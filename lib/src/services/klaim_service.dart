import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KlaimService {
  static final KlaimService _instance = KlaimService._internal();
  factory KlaimService() => _instance;
  KlaimService._internal();

  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get authentication token
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Create authenticated request headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create authenticated request headers for multipart
  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Submit klaim barang
  Future<Map<String, dynamic>> submitKlaim({
    required String idLaporanCocok,
    required String idPenerima,
    File? fotoKlaim,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/klaim');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);
      
      // Add fields
      request.fields['id_laporan_cocok'] = idLaporanCocok;
      request.fields['id_penerima'] = idPenerima;
      
      // Add foto klaim if provided
      if (fotoKlaim != null) {
        final file = await http.MultipartFile.fromPath(
          'foto_klaim',
          fotoKlaim.path,
        );
        request.files.add(file);
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Klaim berhasil dibuat'
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal membuat klaim'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Get all klaim
  Future<Map<String, dynamic>> getAllKlaim() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/klaim'),
        headers: headers,
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal mengambil data klaim'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Get specific klaim by ID
  Future<Map<String, dynamic>> getKlaimById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/klaim/$id'),
        headers: headers,
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal mengambil data klaim'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Update klaim
  Future<Map<String, dynamic>> updateKlaim({
    required String id,
    String? idLaporanCocok,
    String? idPenerima,
    File? fotoKlaim,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/klaim/$id');
      final request = http.MultipartRequest('PUT', uri);
      
      // Add headers
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);
      
      // Add fields
      if (idLaporanCocok != null) {
        request.fields['id_laporan_cocok'] = idLaporanCocok;
      }
      if (idPenerima != null) {
        request.fields['id_penerima'] = idPenerima;
      }
      
      // Add foto klaim if provided
      if (fotoKlaim != null) {
        final file = await http.MultipartFile.fromPath(
          'foto_klaim',
          fotoKlaim.path,
        );
        request.files.add(file);
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Klaim berhasil diupdate'
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal mengupdate klaim'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Delete klaim
  Future<Map<String, dynamic>> deleteKlaim(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/klaim/$id'),
        headers: headers,
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Klaim berhasil dihapus'
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal menghapus klaim'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lokasi_model.dart';

class LokasiService {
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all locations
  Future<List<Lokasi>> getAllLokasi() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/lokasi'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Handle both array and object responses
        List<dynamic> lokasiList;
        if (responseData is List) {
          lokasiList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          lokasiList = responseData['data'] ?? [];
        } else {
          lokasiList = [];
        }
        
        return lokasiList.map((json) => Lokasi.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // Add new location (admin/satpam only)
  Future<bool> addLokasi(String lokasiKlaim) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/lokasi'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'lokasi_klaim': lokasiKlaim,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding location: $e');
      return false;
    }
  }

  // Update location
  Future<bool> updateLokasi(String idLokasi, String lokasiKlaim) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.put(
        Uri.parse('$baseUrl/lokasi/$idLokasi'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'lokasi_klaim': lokasiKlaim,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  // Get location by ID
  Future<Lokasi?> getLokasiById(String idLokasi) async {
    try {
      final allLokasi = await getAllLokasi();
      return allLokasi.firstWhere(
        (lokasi) => lokasi.idLokasiKlaim == idLokasi,
        orElse: () => throw Exception('Location not found'),
      );
    } catch (e) {
      print('Error getting location by ID: $e');
      return null;
    }
  }

  // Delete location (admin only)
  Future<bool> deleteLokasi(String idLokasi) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/lokasi/$idLokasi'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    }
  }
}
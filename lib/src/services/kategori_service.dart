import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/kategori_model.dart';

class KategoriService {
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all categories
  Future<List<Kategori>> getAllKategori() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/kategori'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Handle both array and object responses
        List<dynamic> kategoriList;
        if (responseData is List) {
          kategoriList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          kategoriList = responseData['data'] ?? [];
        } else {
          kategoriList = [];
        }
        
        return kategoriList.map((json) => Kategori.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Add new category (admin only)
  Future<bool> addKategori(String namaKategori) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/kategori'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nama_kategori': namaKategori,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Delete category (admin only)
  Future<bool> deleteKategori(String idKategori) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/kategori/$idKategori'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/report_model.dart';

class MatchingService {
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api/cocok';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Hugging Face API Configuration
  static const String _hfApiUrl = 'https://api-inference.huggingface.co/models/sentence-transformers/all-MiniLM-L6-v2';
  static const String _hfToken = 'YOUR_HUGGING_FACE_TOKEN_HERE'; // TODO: Ganti dengan token HF yang sebenarnya atau gunakan environment variable
  static const double _similarityThreshold = 0.75;
  
  // Fungsi untuk memverifikasi token
  Future<Map<String, dynamic>> _verifyToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (token == null) {
        return {
          'valid': false,
          'error': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }
      
      // Test token dengan memanggil endpoint yang memerlukan autentikasi
      final response = await http.get(
        Uri.parse('https://api-manajemen-barang-hilang.vercel.app/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'valid': true,
          'user': userData
        };
      } else if (response.statusCode == 401) {
        return {
          'valid': false,
          'error': 'Token tidak valid atau sudah kedaluwarsa. Silakan login kembali.'
        };
      } else {
        return {
          'valid': false,
          'error': 'Gagal memverifikasi token (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'error': 'Kesalahan jaringan saat memverifikasi token: $e'
      };
    }
  }

  // Buat pencocokan baru antara laporan hilang dan temuan
  Future<Map<String, dynamic>> createMatching(String laporanHilangId, String laporanTemuanId, {double skorCocok = 0}) async {
    try {
      // Verifikasi token terlebih dahulu
      final tokenVerification = await _verifyToken();
      
      if (tokenVerification['valid'] != true) {
        return {
          'success': false,
          'error': tokenVerification['error'] ?? 'Token tidak valid'
        };
      }
      
      final token = await _secureStorage.read(key: 'auth_token');
      final userData = tokenVerification['user'];
      
      print('=== MATCHING DEBUG INFO ===');
      print('User role: ${userData['role']}');
      print('User ID: ${userData['id']}');
      print('Creating matching with token: ${token?.substring(0, 10)}...');
      print('Laporan hilang ID: $laporanHilangId');
      print('Laporan temuan ID: $laporanTemuanId');
      print('Skor cocok: $skorCocok');
      
      // Cek apakah user memiliki role yang tepat
      if (userData['role'] != 'admin' && userData['role'] != 'satpam') {
        return {
          'success': false,
          'error': 'Anda tidak memiliki izin untuk melakukan pencocokan. Hanya admin dan satpam yang dapat melakukan pencocokan.'
        };
      }
      
      final requestBody = {
        'id_laporan_hilang': laporanHilangId,
        'id_laporan_temuan': laporanTemuanId,
        'skor_cocok': skorCocok,
      };
      
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('=== END DEBUG INFO ===');
      
      if (response.statusCode == 201) {
        print('Matching created successfully');
        return {
          'success': true,
          'data': jsonDecode(response.body)
        };
      } else {
        String errorMessage = 'Gagal membuat pencocokan';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          // Jika response body bukan JSON valid
          errorMessage = 'Server error: ${response.body}';
        }
        
        return {
          'success': false,
          'error': '$errorMessage (Status: ${response.statusCode})',
          'statusCode': response.statusCode,
          'responseBody': response.body
        };
      }
    } catch (e) {
      print('Error creating matching: $e');
      return {
        'success': false,
        'error': 'Terjadi kesalahan jaringan: $e'
      };
    }
  }

  // Ambil semua data pencocokan
  Future<Map<String, dynamic>> getAllMatching() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('Get all matching - Status: ${response.statusCode}');
      print('Get all matching - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> matchingJson = jsonDecode(response.body);
        return {
          'success': true,
          'data': matchingJson.cast<Map<String, dynamic>>()
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal mengambil data pencocokan (Status: ${response.statusCode})',
          'data': []
        };
      }
    } catch (e) {
      print('Error getting matching data: $e');
      return {
        'success': false,
        'error': 'Terjadi kesalahan jaringan: $e',
        'data': []
      };
    }
  }

  // Ambil data pencocokan berdasarkan ID
  Future<Map<String, dynamic>?> getMatchingById(String matchingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$matchingId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error getting matching by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting matching by ID: $e');
      return null;
    }
  }

  // Update skor kecocokan
  Future<bool> updateMatchingScore(String matchingId, double skorCocok) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/$matchingId/skor'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'skor_cocok': skorCocok,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Matching score updated successfully');
        return true;
      } else {
        print('Error updating matching score: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating matching score: $e');
      return false;
    }
  }

  // Hapus data pencocokan (admin only)
  Future<bool> deleteMatching(String matchingId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$matchingId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        print('Matching deleted successfully');
        return true;
      } else {
        print('Error deleting matching: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting matching: $e');
      return false;
    }
  }

  // Metode untuk menghitung similarity menggunakan Hugging Face API
  Future<List<double>> _calculateSimilarity(String sourceText, List<String> candidateTexts) async {
    try {
      final response = await http.post(
        Uri.parse(_hfApiUrl),
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': {
            'source_sentence': sourceText,
            'sentences': candidateTexts,
          }
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> scores = jsonDecode(response.body);
        return scores.cast<double>();
      } else {
        print('Error calculating similarity: ${response.statusCode}');
        print('Response body: ${response.body}');
        return List.filled(candidateTexts.length, 0.0);
      }
    } catch (e) {
      print('Error in similarity calculation: $e');
      return List.filled(candidateTexts.length, 0.0);
    }
  }

  // Metode untuk menggabungkan teks laporan untuk analisis
  String _combineReportText(Report report) {
    return '${report.namaBarang} ${report.deskripsi} ${report.lokasi}';
  }



  // Metode untuk konfirmasi dan menyimpan hasil pencocokan
  Future<Map<String, dynamic>> confirmAutomaticMatch(Report laporanHilang, Report laporanTemuan, double similarityScore) async {
    try {
      // Buat pencocokan menggunakan metode yang sudah ada
      final result = await createMatching(
        laporanHilang.id,
        laporanTemuan.id,
        skorCocok: similarityScore,
      );
      
      if (result['success'] == true) {
        print('Automatic match confirmed and saved: ${laporanHilang.namaBarang} <-> ${laporanTemuan.namaBarang}');
      }
      
      return result;
    } catch (e) {
      print('Error confirming automatic match: $e');
      return {
        'success': false,
        'error': 'Gagal mengkonfirmasi pencocokan: $e'
      };
    }
  }
}
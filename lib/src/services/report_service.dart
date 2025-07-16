import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';


class ReportService {
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api/laporan';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();
  // Klaim service removed

  // Fungsi uploadPhotos dihapus karena foto sekarang diupload langsung dalam saveReport
  
  // Simpan laporan baru ke API
  Future<bool> saveReport(Report report, {List<XFile>? photos}) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      // Buat multipart request
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      
      // Tambahkan header authorization jika ada token
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Tambahkan field data laporan
      request.fields['id_kategori'] = report.kategoriId ?? 'kat-default';
      // Kirim id_lokasi_klaim untuk semua jenis laporan
      if (report.lokasiId != null) {
        request.fields['id_lokasi_klaim'] = report.lokasiId!;
      }
      request.fields['lokasi_kejadian'] = report.lokasi;
      request.fields['nama_barang'] = report.namaBarang;
      request.fields['jenis_laporan'] = report.jenisLaporan;
      request.fields['deskripsi'] = report.deskripsi;
      
      // Tambahkan foto jika ada
      if (photos != null && photos.isNotEmpty) {
        print('Adding ${photos.length} photos to multipart request...');
        for (int i = 0; i < photos.length && i < 3; i++) { // Maksimal 3 foto sesuai backend
          final photo = photos[i];
          final bytes = await photo.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'foto', // Nama field sesuai dengan backend
              bytes,
              filename: photo.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      } else if (report.fotoPaths.isNotEmpty) {
        // Jika foto sudah diupload sebelumnya, kirim sebagai URL
        print('Using existing photo URLs from report: ${report.fotoPaths.length} photos');
        for (int i = 0; i < report.fotoPaths.length; i++) {
          request.fields['url_foto[$i]'] = report.fotoPaths[i];
        }
      }
      
      // Debug logging untuk memeriksa data yang dikirim
      print('Sending multipart request with fields: ${request.fields}');
      print('Number of files: ${request.files.length}');
      
      // Kirim request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        print('Report saved successfully: ${responseData['message']}');
        return true;
      } else {
        print('Error saving report to API: ${response.statusCode}');
        print('Response body: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error saving report: $e');
      return false;
    }
  }



  // Ambil semua laporan dari API
  Future<List<Report>> getAllReports() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = jsonDecode(response.body);
        final reports = reportsJson.map((json) => _convertApiToReport(json)).toList();
        print('Successfully loaded ${reports.length} reports from API');
        return reports;
      } else {
        print('Error getting reports from API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting reports from API: $e');
      return [];
    }
  }



  // Konversi data dari API ke model Report
  Report _convertApiToReport(Map<String, dynamic> apiData) {
    // Konversi foto dengan penanganan berbagai format data
    List<String> fotoPaths = [];
    if (apiData['url_foto'] != null) {
      if (apiData['url_foto'] is List) {
        // Jika url_foto adalah array
        fotoPaths = List<String>.from(apiData['url_foto']);
      } else if (apiData['url_foto'] is String) {
        // Jika url_foto adalah string tunggal
        fotoPaths = [apiData['url_foto']];
      }
    }
    
    // Debug logging untuk memeriksa data foto
    print('Converting report ${apiData['id_laporan']}: foto count = ${fotoPaths.length}');
    if (fotoPaths.isNotEmpty) {
      print('Photo URLs: ${fotoPaths.join(", ")}');
    }
    
    return Report(
      id: apiData['id_laporan'] ?? '',
      jenisLaporan: apiData['jenis_laporan'] ?? '',
      namaBarang: apiData['nama_barang'] ?? '',
      lokasi: apiData['lokasi_kejadian'] ?? '',
      kategoriId: apiData['id_kategori'],
      lokasiId: apiData['id_lokasi_klaim'],
      tanggalKejadian: apiData['waktu_laporan'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(apiData['waktu_laporan']['_seconds'] * 1000)
          : DateTime.now(),
      deskripsi: apiData['deskripsi'] ?? '',
      fotoPaths: fotoPaths,
      tanggalDibuat: apiData['waktu_laporan'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(apiData['waktu_laporan']['_seconds'] * 1000)
          : DateTime.now(),
      status: apiData['status'] ?? 'proses',
      userId: apiData['id_user'] ?? '',
      matchedReportId: null, // Akan dihandle terpisah jika ada
    );
  }

  // Ambil laporan berdasarkan jenis
  Future<List<Report>> getReportsByType(String jenisLaporan) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?jenis_laporan=$jenisLaporan'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = jsonDecode(response.body);
        final reports = reportsJson.map((json) => _convertApiToReport(json)).toList();
        print('Successfully loaded ${reports.length} reports of type $jenisLaporan from API');
        return reports;
      } else {
        print('Error getting reports by type from API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting reports by type from API: $e');
      return [];
    }
  }

  // Ambil laporan berdasarkan user ID
  Future<List<Report>> getReportsByUserId(String userId) async {
    try {
      // Karena API tidak memiliki endpoint khusus untuk user, ambil semua dan filter
      final allReports = await getAllReports();
      final userReports = allReports.where((report) => report.userId == userId).toList();
      print('Successfully loaded ${userReports.length} reports for user $userId from API');
      return userReports;
    } catch (e) {
      print('Error getting reports by user ID: $e');
      return [];
    }
  }

  // Hapus laporan
  Future<bool> deleteReport(String reportId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Report deleted successfully from API');
        return true;
      } else {
        print('Error deleting report from API: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  // Update status laporan
  Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/$reportId/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': newStatus,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Report status updated successfully via API');
        return true;
      } else {
        print('Error updating report status via API: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }


  
  // Klaim functionality removed

  // Ambil laporan yang perlu diverifikasi (untuk satpam)
  Future<List<Report>> getReportsForVerification() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?status=proses'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = jsonDecode(response.body);
        final reports = reportsJson.map((json) => _convertApiToReport(json)).toList();
        print('Successfully loaded ${reports.length} reports for verification from API');
        return reports;
      } else {
        print('Error getting reports for verification from API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting reports for verification: $e');
      return [];
    }
  }

  // Ambil laporan berdasarkan ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$reportId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final reportJson = jsonDecode(response.body);
        final report = _convertApiToReport(reportJson);
        print('Successfully loaded report ${report.namaBarang} from API');
        return report;
      } else {
        print('Error getting report by ID from API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting report by ID: $e');
      return null;
    }
  }

  // Ambil data cocok berdasarkan report ID
  Future<Map<String, dynamic>?> getCocokByReportId(String reportId) async {
    try {
      const String cocokBaseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api/cocok';
      final token = await _secureStorage.read(key: 'auth_token');
      
      final response = await http.get(
        Uri.parse(cocokBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      print('Getting cocok data for report ID: $reportId');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> cocokList;
        
        // Handle different response formats
        if (responseData is List) {
          cocokList = responseData;
        } else if (responseData is Map && responseData['data'] != null) {
          cocokList = responseData['data'];
        } else {
          print('Unexpected response format: $responseData');
          return null;
        }
        
        print('Found ${cocokList.length} cocok records');
        
        // Cari data cocok yang mengandung reportId sebagai laporan hilang atau temuan
        for (final cocok in cocokList) {
          print('Checking cocok: $cocok');
          if (cocok['id_laporan_hilang'] == reportId || cocok['id_laporan_temuan'] == reportId) {
            // Berdasarkan API cocok.js, ID cocok disimpan sebagai document ID dan dikembalikan sebagai id_laporan_cocok
            final cocokId = cocok['id_laporan_cocok'] ?? cocok['id'];
            final result = {
              'id': cocokId,
              'id_laporan_hilang': cocok['id_laporan_hilang'],
              'id_laporan_temuan': cocok['id_laporan_temuan'],
              'skor_cocok': cocok['skor_cocok'] ?? 0,
            };
            print('Found matching cocok data: $result');
            print('Using cocok ID: $cocokId');
            return result;
          }
        }
        
        print('No matching cocok data found for report ID: $reportId');
        return null;
      } else {
        print('Error getting cocok data from API: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting cocok by report ID: $e');
      return null;
    }
  }
}
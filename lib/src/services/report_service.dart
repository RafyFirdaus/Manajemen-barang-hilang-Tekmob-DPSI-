import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'matching_service.dart';


class ReportService {
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api/laporan';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();
  final MatchingService _matchingService = MatchingService();
  // Klaim service removed

  // Upload foto ke API dan dapatkan URL
  Future<List<String>> uploadPhotos(List<XFile> photos) async {
    final List<String> uploadedUrls = [];
    
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      for (final photo in photos) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
        
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        // Tambahkan file foto
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            bytes,
            filename: photo.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(responseBody);
          if (responseData['url_foto'] != null) {
            uploadedUrls.add(responseData['url_foto']);
            print('Photo uploaded successfully: ${responseData['url_foto']}');
          }
        } else {
          print('Error uploading photo: ${response.statusCode}');
          print('Response: $responseBody');
        }
      }
    } catch (e) {
      print('Error uploading photos: $e');
    }
    
    return uploadedUrls;
  }
  
  // Simpan laporan baru ke API
  Future<bool> saveReport(Report report, {List<XFile>? photos}) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      // Upload foto terlebih dahulu jika ada
      List<String> photoUrls = [];
      if (photos != null && photos.isNotEmpty) {
        print('Uploading ${photos.length} photos...');
        photoUrls = await uploadPhotos(photos);
        print('Successfully uploaded ${photoUrls.length} photos');
      }
      
      // Konversi data sesuai struktur API backend
      final apiData = {
        'id_kategori': report.kategoriId ?? 'kat-default',
        'id_lokasi_klaim': report.lokasiId,
        'lokasi_kejadian': report.lokasi,
        'nama_barang': report.namaBarang,
        'jenis_laporan': report.jenisLaporan,
        'deskripsi': report.deskripsi,
        // Gunakan URL foto yang sudah diupload
        'url_foto': photoUrls,
      };
      
      // Debug logging untuk memeriksa data yang dikirim
      print('Saving report with ${photoUrls.length} photo URLs');
      if (photoUrls.isNotEmpty) {
        print('Photo URLs: ${photoUrls.join(", ")}');
      }
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apiData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Report saved successfully: ${responseData['message']}');
        return true;
      } else {
        print('Error saving report to API: ${response.statusCode}');
        print('Response body: ${response.body}');
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

  // Match dua laporan menggunakan API
  Future<Map<String, dynamic>> matchReports(String laporanHilangId, String laporanTemuanId, {double skorCocok = 0}) async {
    try {
      // Gunakan MatchingService untuk membuat pencocokan
      final result = await _matchingService.createMatching(
        laporanHilangId, 
        laporanTemuanId, 
        skorCocok: skorCocok
      );
      
      if (result['success'] == true) {
        // Ambil data laporan untuk notifikasi
        final report1 = await getReportById(laporanHilangId);
        final report2 = await getReportById(laporanTemuanId);
        
        if (report1 != null && report2 != null) {
          // Buat notifikasi untuk kedua user
          final notification1 = NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Laporan Dicocokkan',
            message: 'Laporan ${report1.namaBarang} telah dicocokkan dengan laporan lain!',
            reportId: report1.id,
            reportName: report1.namaBarang,
            oldStatus: 'proses',
            newStatus: 'cocok',
            createdAt: DateTime.now(),
            isRead: false,
            userId: report1.userId,
          );
          
          final notification2 = NotificationModel(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            title: 'Laporan Dicocokkan',
            message: 'Laporan ${report2.namaBarang} telah dicocokkan dengan laporan lain!',
            reportId: report2.id,
            reportName: report2.namaBarang,
            oldStatus: 'proses',
            newStatus: 'cocok',
            createdAt: DateTime.now(),
            isRead: false,
            userId: report2.userId,
          );
          
          await _notificationService.addNotification(notification1);
          await _notificationService.addNotification(notification2);
        }
      }
      
      return result;
    } catch (e) {
      print('Error matching reports: $e');
      return {
        'success': false,
        'error': 'Terjadi kesalahan saat mencocokkan laporan: $e'
      };
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
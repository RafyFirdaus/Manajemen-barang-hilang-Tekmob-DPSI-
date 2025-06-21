import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/report_model.dart';

class ReportService {
  static const String _reportsKey = 'reports';
  static const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Simpan laporan baru ke API
  Future<bool> saveReport(Report report) async {
    try {
      // Simpan ke local storage sebagai backup
      await _saveReportLocally(report);
      
      // Kirim ke API
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(report.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error saving report to API: ${response.statusCode}');
        return true; // Return true karena sudah tersimpan di local
      }
    } catch (e) {
      print('Error saving report: $e');
      // Tetap return true karena sudah tersimpan di local storage
      return true;
    }
  }

  // Simpan laporan ke local storage
  Future<bool> _saveReportLocally(Report report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getAllReportsLocally();
      reports.add(report);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      return true;
    } catch (e) {
      print('Error saving report locally: $e');
      return false;
    }
  }

  // Ambil semua laporan dari API dengan fallback ke local
  Future<List<Report>> getAllReports() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = jsonDecode(response.body)['data'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        // Fallback ke local storage
        return await _getAllReportsLocally();
      }
    } catch (e) {
      print('Error getting reports from API: $e');
      // Fallback ke local storage
      return await _getAllReportsLocally();
    }
  }

  // Ambil semua laporan dari local storage
  Future<List<Report>> _getAllReportsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsString = prefs.getString(_reportsKey);
      
      if (reportsString == null) {
        return [];
      }
      
      final List<dynamic> reportsJson = jsonDecode(reportsString);
      return reportsJson.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      print('Error getting reports locally: $e');
      return [];
    }
  }

  // Ambil laporan berdasarkan jenis
  Future<List<Report>> getReportsByType(String jenisLaporan) async {
    final allReports = await getAllReports();
    return allReports.where((report) => report.jenisLaporan == jenisLaporan).toList();
  }

  // Ambil laporan berdasarkan user ID
  Future<List<Report>> getReportsByUserId(String userId) async {
    final allReports = await getAllReports();
    return allReports.where((report) => report.userId == userId).toList();
  }

  // Hapus laporan
  Future<bool> deleteReport(String reportId) async {
    try {
      // Hapus dari API
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/reports/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      // Hapus dari local storage juga
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getAllReportsLocally();
      reports.removeWhere((report) => report.id == reportId);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  // Update status laporan
  Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      // Update di API
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.put(
        Uri.parse('$baseUrl/reports/$reportId/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );
      
      // Update di local storage juga
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getAllReportsLocally();
      
      final reportIndex = reports.indexWhere((report) => report.id == reportId);
      if (reportIndex != -1) {
        final oldReport = reports[reportIndex];
        final updatedReport = Report(
          id: oldReport.id,
          jenisLaporan: oldReport.jenisLaporan,
          namaBarang: oldReport.namaBarang,
          lokasi: oldReport.lokasi,
          tanggalKejadian: oldReport.tanggalKejadian,
          deskripsi: oldReport.deskripsi,
          fotoPaths: oldReport.fotoPaths,
          tanggalDibuat: oldReport.tanggalDibuat,
          status: newStatus,
          userId: oldReport.userId,
        );
        
        reports[reportIndex] = updatedReport;
        
        final reportsJson = reports.map((r) => r.toJson()).toList();
        await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      }
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }

  // Ambil laporan yang perlu diverifikasi (untuk satpam)
  Future<List<Report>> getReportsForVerification() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/reports/verification'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = jsonDecode(response.body)['data'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        // Fallback: ambil laporan dengan status "Menunggu Verifikasi" dari local
        final allReports = await _getAllReportsLocally();
        return allReports.where((report) => report.status == 'Menunggu Verifikasi').toList();
      }
    } catch (e) {
      print('Error getting reports for verification: $e');
      // Fallback ke local storage
      final allReports = await _getAllReportsLocally();
      return allReports.where((report) => report.status == 'Menunggu Verifikasi').toList();
    }
  }
}
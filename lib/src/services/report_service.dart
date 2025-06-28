import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/report_model.dart';
import 'notification_service.dart';

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
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/reports/user/$userId'),
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
        final allReports = await _getAllReportsLocally();
        return allReports.where((report) => report.userId == userId).toList();
      }
    } catch (e) {
      print('Error getting reports by user ID from API: $e');
      // Fallback ke local storage
      final allReports = await _getAllReportsLocally();
      return allReports.where((report) => report.userId == userId).toList();
    }
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
        final oldStatus = oldReport.status;
        
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
          matchedReportId: oldReport.matchedReportId,
        );
        
        reports[reportIndex] = updatedReport;
        
        final reportsJson = reports.map((r) => r.toJson()).toList();
        await prefs.setString(_reportsKey, jsonEncode(reportsJson));
        
        // Buat notifikasi jika status berubah dari 'Proses' ke 'Cocok'
        if (oldStatus.toLowerCase() == 'proses' && newStatus.toLowerCase() == 'cocok') {
          final notificationService = NotificationService();
          await notificationService.createStatusChangeNotification(
            userId: oldReport.userId,
            reportId: reportId,
            reportName: oldReport.namaBarang,
            oldStatus: oldStatus,
            newStatus: newStatus,
          );
        }
      }
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }

  // Match dua laporan dan update status keduanya menjadi 'Cocok'
  Future<bool> matchReports(String reportId1, String reportId2) async {
    try {
      // Update di local storage
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getAllReportsLocally();
      
      final report1Index = reports.indexWhere((report) => report.id == reportId1);
      final report2Index = reports.indexWhere((report) => report.id == reportId2);
      
      if (report1Index != -1 && report2Index != -1) {
        final oldReport1 = reports[report1Index];
        final oldReport2 = reports[report2Index];
        
        // Update kedua laporan dengan status 'Cocok' dan matchedReportId
        final updatedReport1 = Report(
          id: oldReport1.id,
          jenisLaporan: oldReport1.jenisLaporan,
          namaBarang: oldReport1.namaBarang,
          lokasi: oldReport1.lokasi,
          tanggalKejadian: oldReport1.tanggalKejadian,
          deskripsi: oldReport1.deskripsi,
          fotoPaths: oldReport1.fotoPaths,
          tanggalDibuat: oldReport1.tanggalDibuat,
          status: 'Cocok',
          userId: oldReport1.userId,
          matchedReportId: reportId2,
        );
        
        final updatedReport2 = Report(
          id: oldReport2.id,
          jenisLaporan: oldReport2.jenisLaporan,
          namaBarang: oldReport2.namaBarang,
          lokasi: oldReport2.lokasi,
          tanggalKejadian: oldReport2.tanggalKejadian,
          deskripsi: oldReport2.deskripsi,
          fotoPaths: oldReport2.fotoPaths,
          tanggalDibuat: oldReport2.tanggalDibuat,
          status: 'Cocok',
          userId: oldReport2.userId,
          matchedReportId: reportId1,
        );
        
        reports[report1Index] = updatedReport1;
        reports[report2Index] = updatedReport2;
        
        final reportsJson = reports.map((r) => r.toJson()).toList();
        await prefs.setString(_reportsKey, jsonEncode(reportsJson));
        
        // Buat notifikasi untuk kedua user
        final notificationService = NotificationService();
        await notificationService.createStatusChangeNotification(
          userId: oldReport1.userId,
          reportId: reportId1,
          reportName: oldReport1.namaBarang,
          oldStatus: oldReport1.status,
          newStatus: 'Cocok',
        );
        
        await notificationService.createStatusChangeNotification(
          userId: oldReport2.userId,
          reportId: reportId2,
          reportName: oldReport2.namaBarang,
          oldStatus: oldReport2.status,
          newStatus: 'Cocok',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error matching reports: $e');
      return false;
    }
  }
  
  // Klaim barang - update kedua laporan yang cocok menjadi 'Selesai'
  Future<bool> claimMatchedReports(String reportId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getAllReportsLocally();
      
      final reportIndex = reports.indexWhere((report) => report.id == reportId);
      if (reportIndex == -1) return false;
      
      final currentReport = reports[reportIndex];
      final matchedReportId = currentReport.matchedReportId;
      
      if (matchedReportId == null) {
        // Jika tidak ada matched report, hanya update laporan ini
        return await updateReportStatus(reportId, 'Selesai');
      }
      
      final matchedReportIndex = reports.indexWhere((report) => report.id == matchedReportId);
      if (matchedReportIndex == -1) {
        // Jika matched report tidak ditemukan, hanya update laporan ini
        return await updateReportStatus(reportId, 'Selesai');
      }
      
      // Update kedua laporan menjadi 'Selesai'
      final oldReport1 = reports[reportIndex];
      final oldReport2 = reports[matchedReportIndex];
      
      final updatedReport1 = Report(
        id: oldReport1.id,
        jenisLaporan: oldReport1.jenisLaporan,
        namaBarang: oldReport1.namaBarang,
        lokasi: oldReport1.lokasi,
        tanggalKejadian: oldReport1.tanggalKejadian,
        deskripsi: oldReport1.deskripsi,
        fotoPaths: oldReport1.fotoPaths,
        tanggalDibuat: oldReport1.tanggalDibuat,
        status: 'Selesai',
        userId: oldReport1.userId,
        matchedReportId: oldReport1.matchedReportId,
      );
      
      final updatedReport2 = Report(
        id: oldReport2.id,
        jenisLaporan: oldReport2.jenisLaporan,
        namaBarang: oldReport2.namaBarang,
        lokasi: oldReport2.lokasi,
        tanggalKejadian: oldReport2.tanggalKejadian,
        deskripsi: oldReport2.deskripsi,
        fotoPaths: oldReport2.fotoPaths,
        tanggalDibuat: oldReport2.tanggalDibuat,
        status: 'Selesai',
        userId: oldReport2.userId,
        matchedReportId: oldReport2.matchedReportId,
      );
      
      reports[reportIndex] = updatedReport1;
      reports[matchedReportIndex] = updatedReport2;
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      
      // Buat notifikasi untuk kedua user
      final notificationService = NotificationService();
      await notificationService.createStatusChangeNotification(
        userId: oldReport1.userId,
        reportId: oldReport1.id,
        reportName: oldReport1.namaBarang,
        oldStatus: 'Cocok',
        newStatus: 'Selesai',
      );
      
      await notificationService.createStatusChangeNotification(
        userId: oldReport2.userId,
        reportId: oldReport2.id,
        reportName: oldReport2.namaBarang,
        oldStatus: 'Cocok',
        newStatus: 'Selesai',
      );
      
      return true;
    } catch (e) {
      print('Error claiming matched reports: $e');
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
        return allReports.where((report) => report.status == 'Proses').toList();
      }
    } catch (e) {
      print('Error getting reports for verification: $e');
      // Fallback ke local storage
      final allReports = await _getAllReportsLocally();
      return allReports.where((report) => report.status == 'Proses').toList();
    }
  }
}
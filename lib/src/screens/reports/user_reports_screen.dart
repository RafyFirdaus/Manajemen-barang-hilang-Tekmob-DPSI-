import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/report_detail_modal.dart';
import 'package:intl/intl.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen>
    with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  final AuthService _authService = AuthService();
  late TabController _tabController;
  
  List<Report> _laporanHilang = [];
  List<Report> _laporanTemuan = [];
  bool _isLoading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserReports() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user ID
      final userData = await _authService.getUserData();
      _currentUserId = userData['id'] ?? '';

      // Get user's reports
      final reports = await _reportService.getReportsByUserId(_currentUserId);
      
      if (mounted) {
        setState(() {
          _laporanHilang = reports
              .where((r) => r.jenisLaporan == 'Laporan Kehilangan')
              .toList();
          _laporanTemuan = reports
              .where((r) => r.jenisLaporan == 'Laporan Temuan')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user reports: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshReports() async {
    await _loadUserReports();
  }

  void _showReportDetail(Report report) {
    ReportDetailModal.show(
      context: context,
      report: report,
      showVerificationActions: false,
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.jenisLaporan == 'Hilang'
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.jenisLaporan,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: report.jenisLaporan == 'Hilang'
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(report.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.namaBarang,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.lokasi,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(report.tanggalKejadian),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.orange;
      case 'cocok':
        return Colors.green;
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTabContent(List<Report> reports, String emptyMessage) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/src/assets/images/ri_file-list-line.svg',
              height: 80,
              width: 80,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReports,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _buildReportCard(reports[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1F41BB),
          ),
        ),
        title: Text(
          'Riwayat Laporan Saya',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F41BB),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshReports,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF1F41BB),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1F41BB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF1F41BB),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              text: 'Barang Hilang (${_laporanHilang.length})',
            ),
            Tab(
              text: 'Barang Temuan (${_laporanTemuan.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(
                  _laporanHilang,
                  'Belum ada laporan barang hilang',
                ),
                _buildTabContent(
                  _laporanTemuan,
                  'Belum ada laporan barang temuan',
                ),
              ],
            ),
    );
  }
}
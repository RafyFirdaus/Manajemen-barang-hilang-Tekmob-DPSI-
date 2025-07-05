import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/report_detail_modal.dart';
import '../../widgets/report_detail_card.dart';

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
              .where((r) => r.jenisLaporan == 'hilang')
              .toList();
          _laporanTemuan = reports
              .where((r) => r.jenisLaporan == 'temuan')
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
    ReportDetailModal.showReportDetailModal(
      context: context,
      report: report,
      showVerificationActions: false,
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => _showReportDetail(report),
        child: ReportDetailCard(
          report: report,
          showMatchButton: false,
        ),
      ),
    );
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
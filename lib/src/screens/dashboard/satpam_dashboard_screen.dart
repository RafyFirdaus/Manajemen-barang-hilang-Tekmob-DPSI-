import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/report_list_view.dart';
import '../../widgets/report_detail_modal.dart';
import '../auth/login_screen.dart';
import '../matching/matching_screen.dart';
import '../claim/claim_form_screen.dart';

class SatpamDashboardScreen extends StatefulWidget {
  const SatpamDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SatpamDashboardScreen> createState() => _SatpamDashboardScreenState();
}

class _SatpamDashboardScreenState extends State<SatpamDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _username = '';
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  List<Report> _allReports = [];
  List<Report> _laporanHilang = [];
  List<Report> _laporanTemuan = [];
  List<Report> _laporanSelesai = [];
  List<Report> _filteredLaporanHilang = [];
  List<Report> _filteredLaporanTemuan = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      // ignore: unnecessary_null_comparison
      if (userData != null) {
        setState(() {
          _username = userData['username'] ?? 'Satpam';
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'Satpam';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'Satpam';
        _isLoading = false;
      });
    }
  }



  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getAllReports();
      setState(() {
        _allReports = reports;
        // Filter laporan yang belum selesai untuk dashboard utama
        _laporanHilang = reports.where((report) => report.jenisLaporan == 'Laporan Kehilangan' && report.status != 'Selesai').toList();
        _laporanTemuan = reports.where((report) => report.jenisLaporan == 'Laporan Temuan' && report.status != 'Selesai').toList();
        // Laporan selesai untuk halaman kelola
        _laporanSelesai = reports.where((report) => report.status == 'Selesai').toList();
        _filterReports();
      });
    } catch (e) {
      print('Error loading reports: $e');
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _filterReports() {
    if (_searchQuery.isEmpty) {
      _filteredLaporanHilang = List.from(_laporanHilang);
      _filteredLaporanTemuan = List.from(_laporanTemuan);
    } else {
      _filteredLaporanHilang = _laporanHilang.where((report) {
        return report.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      _filteredLaporanTemuan = _laporanTemuan.where((report) {
        return report.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterReports();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  Widget _buildHomeContent() {
    return Column(
      children: [
        DashboardHeader(
          username: _username,
          tabController: _tabController,
          tabTitles: const [
            'Laporan Barang Hilang',
            'Laporan Barang Temuan',
          ],
          searchController: _searchController,
          onFilterPressed: () {
            // Filter action
          },
          onSearchChanged: _onSearchChanged,
        ),
        
        // Tab Bar View Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLaporanHilangContent(),
              _buildLaporanTemuanContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanHilangContent() {
    return ReportListView(
      reports: _filteredLaporanHilang,
      onReportTap: _showReportDetail,
      emptyMessage: _searchQuery.isEmpty 
          ? 'Belum ada laporan barang hilang untuk diverifikasi'
          : 'Tidak ada laporan barang hilang yang sesuai dengan pencarian "$_searchQuery"',
    );
  }

  Widget _buildLaporanTemuanContent() {
    return ReportListView(
      reports: _filteredLaporanTemuan,
      onReportTap: _showReportDetail,
      emptyMessage: _searchQuery.isEmpty 
          ? 'Belum ada laporan barang temuan untuk diverifikasi'
          : 'Tidak ada laporan barang temuan yang sesuai dengan pencarian "$_searchQuery"',
    );
  }

  Widget _buildKelolaContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Laporan Selesai',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReportListView(
            reports: _laporanSelesai,
            onReportTap: _showCompletedReportDetail,
            emptyMessage: 'Belum ada laporan yang selesai',
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Fitur ini sedang dalam pengembangan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      _buildHomeContent(),
      _buildKelolaContent(),
      MatchingScreen(onReportsUpdated: _loadReports),
      _buildPlaceholderContent('Profil'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/src/assets/images/Box_open_fill.svg',
              height: 35,
              width: 35,
            ),
            const SizedBox(width: 12),
            Text(
              'Manajemen Barang Hilang',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F41BB),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: SvgPicture.asset(
              'lib/src/assets/images/material-symbols_logout.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1F41BB),
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/material-symbols_home-rounded.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 0 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/ri_file-list-line.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 1 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Riwayat Selesai',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/mdi_folder-sync.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 2 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Pencocokan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/iconamoon_profile-light.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 3 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _markAsFound(Report report) async {
    try {
      await _reportService.claimMatchedReports(report.id);
      
      
      _loadReports(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil ditandai sebagai selesai'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menandai laporan sebagai selesai'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportDetail(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailModal(
        report: report,
        showVerificationActions: false,
        onApprove: () => _markAsFound(report),
        onClaim: () => _navigateToClaimForm(report),
      ),
    );
  }

  void _showCompletedReportDetail(Report report) {
    ReportDetailModal.show(
      context: context,
      report: report,
      showVerificationActions: false, // Laporan selesai tidak perlu tombol verifikasi
    );
  }



  Future<void> _navigateToClaimForm(Report report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaimFormScreen(report: report),
      ),
    );
    
    // Jika form klaim berhasil disubmit, refresh data
    if (result == true) {
      _loadReports();
    }
  }


}
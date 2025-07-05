import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../models/klaim_model.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/klaim_service.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/report_list_view.dart';
import '../../widgets/report_detail_modal.dart';
import '../auth/login_screen.dart';
import '../matching/matching_screen.dart';
import '../profile/profile_screen.dart';

class SatpamDashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const SatpamDashboardScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<SatpamDashboardScreen> createState() => _SatpamDashboardScreenState();
}

class _SatpamDashboardScreenState extends State<SatpamDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _username = '';
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();
  final KlaimService _klaimService = KlaimService();
  late TabController _tabController;
  late TabController _riwayatTabController;
  final TextEditingController _searchController = TextEditingController();
  List<Report> _laporanHilang = [];
  List<Report> _laporanTemuan = [];
  List<Report> _laporanSelesai = [];
  List<Report> _laporanSelesaiHilang = [];
  List<Report> _laporanSelesaiTemuan = [];
  List<Report> _filteredLaporanHilang = [];
  List<Report> _filteredLaporanTemuan = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _tabController = TabController(length: 2, vsync: this);
    _riwayatTabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _riwayatTabController.dispose();
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
        // Filter laporan yang belum selesai untuk dashboard utama
        _laporanHilang = reports.where((report) => report.jenisLaporan == 'hilang' && report.status != 'selesai').toList();
         _laporanTemuan = reports.where((report) => report.jenisLaporan == 'temuan' && report.status != 'selesai').toList();
        // Laporan selesai untuk halaman kelola
        _laporanSelesai = reports.where((report) => report.status == 'selesai').toList();
        _laporanSelesaiHilang = _laporanSelesai.where((report) => report.jenisLaporan == 'hilang').toList();
        _laporanSelesaiTemuan = _laporanSelesai.where((report) => report.jenisLaporan == 'temuan').toList();
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
          onRefreshPressed: _loadReports,
          onSearchChanged: _onSearchChanged,
        ),
        
        // Tab Bar View Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: _loadReports,
                child: _buildLaporanHilangContent(),
              ),
              RefreshIndicator(
                onRefresh: _loadReports,
                child: _buildLaporanTemuanContent(),
              ),
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
        // Tab Bar untuk Riwayat Selesai
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _riwayatTabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            indicator: BoxDecoration(
              color: const Color(0xFF1F41BB),
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                text: 'Barang Hilang (${_laporanSelesaiHilang.length})',
              ),
              Tab(
                text: 'Barang Temuan (${_laporanSelesaiTemuan.length})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _riwayatTabController,
            children: [
              RefreshIndicator(
                onRefresh: _loadReports,
                child: ReportListView(
                  reports: _laporanSelesaiHilang,
                  onReportTap: _showCompletedReportDetail,
                  emptyMessage: 'Belum ada laporan barang hilang yang selesai',
                ),
              ),
              RefreshIndicator(
                onRefresh: _loadReports,
                child: ReportListView(
                  reports: _laporanSelesaiTemuan,
                  onReportTap: _showCompletedReportDetail,
                  emptyMessage: 'Belum ada laporan barang temuan yang selesai',
                ),
              ),
            ],
          ),
        ),
      ],
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
      const ProfileScreen(role: 'satpam'),
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
                fontSize: 16,
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
                child: Icon(
                  Icons.person_outline,
                  size: 24,
                  color: _selectedIndex == 3 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsFound(Report report) async {
    try {
      // Note: Untuk implementasi yang lengkap, perlu mendapatkan matching ID dari API
      // Sementara menggunakan placeholder    
      
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

  void _showReportDetail(Report report) async {
    // Cek apakah laporan memiliki status 'cocok' atau 'selesai' dan ambil data cocok
    Map<String, dynamic>? cocokData;
    String? idLaporanCocok;
    String? idPenerima;
    Klaim? klaimData;
    String? namaSatpam;
    
    if (report.status.toLowerCase() == 'cocok' || report.status.toLowerCase() == 'selesai') {
      try {
        cocokData = await _reportService.getCocokByReportId(report.id);
        if (cocokData != null) {
          idLaporanCocok = cocokData['id']?.toString();
          // ID penerima adalah user yang membuat laporan hilang
          if (report.jenisLaporan == 'hilang') {
            idPenerima = report.userId.toString();
          } else {
            // Jika ini laporan temuan, ambil user ID dari laporan hilang yang dicocokkan
            final idLaporanHilang = cocokData['id_laporan_hilang'];
            if (idLaporanHilang != null) {
              final laporanHilang = await _reportService.getReportById(idLaporanHilang);
              idPenerima = laporanHilang?.userId.toString();
            }
          }
          
          // Jika status selesai, ambil data klaim
          if (report.status.toLowerCase() == 'selesai' && idLaporanCocok != null) {
            try {
              final klaimResponse = await _klaimService.getAllKlaim();
              print('Klaim response: $klaimResponse');
              
              if (klaimResponse['success'] == true) {
                final dynamic klaimData_raw = klaimResponse['data'];
                print('Raw klaim data: $klaimData_raw');
                print('Klaim data type: ${klaimData_raw.runtimeType}');
                
                List<dynamic> klaimList = [];
                
                // Handle different response structures
                if (klaimData_raw is List) {
                  klaimList = klaimData_raw;
                } else if (klaimData_raw is Map && klaimData_raw.containsKey('data')) {
                  klaimList = klaimData_raw['data'] ?? [];
                } else if (klaimData_raw is Map) {
                  // If it's a single object, wrap it in a list
                  klaimList = [klaimData_raw];
                }
                
                print('Processed klaim list: $klaimList');
                
                final klaimJson = klaimList.firstWhere(
                  (k) {
                    print('Checking klaim item: $k');
                    print('Comparing ${k['id_laporan_cocok']} with $idLaporanCocok');
                    return k['id_laporan_cocok'] == idLaporanCocok;
                  },
                  orElse: () => null,
                );
                
                print('Found klaim JSON: $klaimJson');
                
                if (klaimJson != null) {
                  try {
                    klaimData = Klaim.fromJson(klaimJson);
                    print('Successfully parsed klaim data: ${klaimData.idKlaim}');
                    
                    // Ambil nama satpam
                    try {
                      final satpamData = await _authService.getUserById(klaimData.idSatpam);
                      namaSatpam = satpamData?['username'] ?? 'Satpam';
                    } catch (e) {
                      print('Error getting satpam data: $e');
                      namaSatpam = 'Satpam';
                    }
                  } catch (parseError) {
                    print('Error parsing klaim JSON: $parseError');
                    print('Klaim JSON structure: $klaimJson');
                  }
                }
              }
            } catch (e) {
              print('Error getting klaim data: $e');
            }
          }
        }
      } catch (e) {
        print('Error getting cocok data: $e');
        // Reset values jika terjadi error
        idLaporanCocok = null;
        idPenerima = null;
      }
    }
    
    ReportDetailModal.show(
      context: context,
      report: report,
      showVerificationActions: false,
      onApprove: () => _markAsFound(report),
      showClaimButton: true,
      idLaporanCocok: idLaporanCocok,
      idPenerima: idPenerima,
      klaimData: klaimData,
      namaSatpam: namaSatpam,
    );
  }

  void _showCompletedReportDetail(Report report) async {
    // Ambil data klaim untuk laporan selesai
    Klaim? klaimData;
    String? namaSatpam;
    
    try {
      // Cari klaim berdasarkan laporan cocok yang terkait dengan laporan ini
      final cocokData = await _reportService.getCocokByReportId(report.id);
      if (cocokData != null) {
        final idLaporanCocok = cocokData['id']?.toString();
        if (idLaporanCocok != null) {
          // Ambil semua klaim dan cari yang sesuai dengan id_laporan_cocok
          final klaimResponse = await _klaimService.getAllKlaim();
          print('Completed report klaim response: $klaimResponse');
          
          if (klaimResponse['success'] == true) {
            final dynamic klaimData_raw = klaimResponse['data'];
            print('Completed report raw klaim data: $klaimData_raw');
            print('Completed report klaim data type: ${klaimData_raw.runtimeType}');
            
            List<dynamic> klaimList = [];
            
            // Handle different response structures
            if (klaimData_raw is List) {
              klaimList = klaimData_raw;
            } else if (klaimData_raw is Map && klaimData_raw.containsKey('data')) {
              klaimList = klaimData_raw['data'] ?? [];
            } else if (klaimData_raw is Map) {
              // If it's a single object, wrap it in a list
              klaimList = [klaimData_raw];
            }
            
            print('Completed report processed klaim list: $klaimList');
            
            final klaimJson = klaimList.firstWhere(
              (k) {
                print('Completed report checking klaim item: $k');
                print('Completed report comparing ${k['id_laporan_cocok']} with $idLaporanCocok');
                return k['id_laporan_cocok'] == idLaporanCocok;
              },
              orElse: () => null,
            );
            
            print('Completed report found klaim JSON: $klaimJson');
            
            if (klaimJson != null) {
              try {
                klaimData = Klaim.fromJson(klaimJson);
                print('Completed report successfully parsed klaim data: ${klaimData.idKlaim}');
                
                // Ambil nama satpam
                try {
                  final satpamData = await _authService.getUserById(klaimData.idSatpam);
                  namaSatpam = satpamData?['username'] ?? 'Satpam';
                } catch (e) {
                  print('Completed report error getting satpam data: $e');
                  namaSatpam = 'Satpam';
                }
              } catch (parseError) {
                print('Completed report error parsing klaim JSON: $parseError');
                print('Completed report klaim JSON structure: $klaimJson');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error getting klaim data: $e');
    }
    
    ReportDetailModal.show(
      context: context,
      report: report,
      showVerificationActions: false, // Laporan selesai tidak perlu tombol verifikasi
      klaimData: klaimData,
      namaSatpam: namaSatpam,
    );
  }

  // Claim functionality removed

}
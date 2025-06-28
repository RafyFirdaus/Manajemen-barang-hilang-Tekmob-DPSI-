import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../add_report_screen.dart';
import '../reports/user_reports_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../models/report_model.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/report_list_view.dart';
import '../../widgets/report_detail_modal.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _username = '';
  String _currentUserId = '';
  bool _isLoading = true;
  int _unreadNotificationCount = 0;
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  List<Report> _allReports = [];
  List<Report> _laporanHilang = [];
  List<Report> _laporanTemuan = [];

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
      if (mounted) {
        setState(() {
          _username = userData['username'] ?? 'User';
          _currentUserId = userData['id'] ?? '';
          _isLoading = false;
        });
        // Load notification count
        await _loadNotificationCount();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotificationCount() async {
    if (_currentUserId.isNotEmpty) {
      try {
        final count = await _notificationService.getUnreadCountForUser(_currentUserId);
        setState(() {
          _unreadNotificationCount = count;
        });
      } catch (e) {
        print('Error loading notification count: $e');
      }
    }
  }



  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getAllReports();
      if (mounted) {
        setState(() {
          _allReports = reports;
          // Filter laporan yang tidak berstatus 'Selesai' untuk dashboard user
          _laporanHilang = reports.where((r) => r.jenisLaporan == 'Laporan Kehilangan' && r.status != 'Selesai').toList();
          _laporanTemuan = reports.where((r) => r.jenisLaporan == 'Laporan Temuan' && r.status != 'Selesai').toList();
        });
        // Refresh notification count
        _loadNotificationCount();
      }
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

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to User Reports Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserReportsScreen(),
        ),
      ).then((_) {
        // Refresh reports when returning from reports screen
        _loadReports();
      });
    } else if (index == 2) {
      // Navigate to Add Report Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddReportScreen(),
        ),
      ).then((_) {
        // Refresh reports when returning from add report screen
        _loadReports();
      });
    } else if (index == 3) {
      // Navigate to Notifications Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
        ),
      ).then((_) {
        // Refresh notification count when returning
        _loadNotificationCount();
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
      reports: _laporanHilang,
      onReportTap: _showReportDetail,
      emptyMessage: 'Belum ada laporan barang hilang',
    );
  }

  Widget _buildLaporanTemuanContent() {
    return ReportListView(
      reports: _laporanTemuan,
      onReportTap: _showReportDetail,
      emptyMessage: 'Belum ada laporan barang temuan',
    );
  }



  void _showReportDetail(Report report) {
    ReportDetailModal.show(
      context: context,
      report: report,
      showVerificationActions: false, // User dashboard doesn't need verification actions
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
            '$title Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'lib/src/assets/images/mingcute_notification-line.svg',
            height: 80,
            width: 80,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade400,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fitur ini sedang dikembangkan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
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
      _buildPlaceholderContent('Laporan'),
      _buildPlaceholderContent('Tambah Laporan'),
      _buildNotificationPlaceholder(),
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
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/icon-park-outline_add.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 2 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Tambah',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'lib/src/assets/images/mingcute_notification-line.svg',
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 3 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (_unreadNotificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SvgPicture.asset(
                  'lib/src/assets/images/iconamoon_profile-light.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 4 ? const Color(0xFF1F41BB) : Colors.grey.shade400,
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
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../widgets/report_list_view.dart';
import 'matching_detail_screen.dart';

class MatchingScreen extends StatefulWidget {
  final VoidCallback? onReportsUpdated;
  
  const MatchingScreen({Key? key, this.onReportsUpdated}) : super(key: key);

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  List<Report> _allReports = [];
  List<Report> _filteredReports = [];
  String _selectedFilter = 'Semua'; // 'Semua', 'Kehilangan', 'Temuan'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getAllReports();
      setState(() {
        // Exclude reports with status 'selesai' and 'cocok' from matching screen
        _allReports = reports.where((report) => 
          report.status != 'selesai' && 
          report.status.toLowerCase() != 'cocok'
        ).toList();
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'Semua') {
        _filteredReports = _allReports;
      } else if (_selectedFilter == 'Kehilangan') {
        _filteredReports = _allReports
            .where((report) => report.jenisLaporan == 'hilang')
            .toList();
      } else if (_selectedFilter == 'Temuan') {
        _filteredReports = _allReports
            .where((report) => report.jenisLaporan == 'temuan')
            .toList();
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Laporan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Semua Laporan'),
                leading: Radio<String>(
                  value: 'Semua',
                  groupValue: _selectedFilter,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFilter = value!;
                      _applyFilter();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Laporan Kehilangan'),
                leading: Radio<String>(
                  value: 'Kehilangan',
                  groupValue: _selectedFilter,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFilter = value!;
                      _applyFilter();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Laporan Temuan'),
                leading: Radio<String>(
                  value: 'Temuan',
                  groupValue: _selectedFilter,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFilter = value!;
                      _applyFilter();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onReportTap(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchingDetailScreen(
          selectedReport: report,
          allReports: _allReports,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadReports(); // Refresh reports if matching was successful
        // Panggil callback untuk refresh dashboard
        if (widget.onReportsUpdated != null) {
          widget.onReportsUpdated!();
        }
      }
    });
  }

  Widget _buildManualTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with filter button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Laporan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  if (_selectedFilter != 'Semua')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F41BB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedFilter,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF1F41BB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showFilterDialog,
                    icon: Icon(
                      Icons.filter_list,
                      color: const Color(0xFF1F41BB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Report list
        Expanded(
          child: ReportListView(
            reports: _filteredReports,
            onReportTap: _onReportTap,
            emptyMessage: 'Belum ada laporan untuk dicocokkan',
          ),
        ),
      ],
    );
  }

  Widget _buildAutomaticTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Pencocokan Otomatis',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Pencocokan Laporan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F41BB),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1F41BB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF1F41BB),
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Manual'),
            Tab(text: 'Otomatis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualTab(),
          _buildAutomaticTab(),
        ],
      ),
    );
  }
}
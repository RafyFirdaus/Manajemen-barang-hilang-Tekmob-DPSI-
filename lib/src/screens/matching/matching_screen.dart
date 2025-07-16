import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/matching_service.dart';
import '../../services/notification_service.dart';
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
  final MatchingService _matchingService = MatchingService();
  final NotificationService _notificationService = NotificationService();
  List<Report> _allReports = [];
  List<Report> _filteredReports = [];
  String _selectedFilter = 'Semua'; // 'Semua', 'Kehilangan', 'Temuan'
  bool _isLoading = true;
  
  // Automatic matching variables
  List<Map<String, dynamic>> _automaticMatches = [];
  bool _isProcessingAutoMatch = false;
  bool _hasProcessedAutoMatch = false;

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
                          fontSize: 10,
                          color: const Color(0xFF1F41BB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loadReports,
                    icon: Icon(
                      Icons.refresh,
                      color: const Color(0xFF1F41BB),
                    ),
                  ),
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
          child: RefreshIndicator(
            onRefresh: _loadReports,
            child: ReportListView(
              reports: _filteredReports,
              onReportTap: _onReportTap,
              emptyMessage: 'Belum ada laporan untuk dicocokkan',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _performAutomaticMatching() async {
    setState(() {
      _isProcessingAutoMatch = true;
    });

    try {
      // Ambil semua laporan yang statusnya 'proses'
      final allReports = await _reportService.getAllReports();
      final processReports = allReports.where((r) => r.status.toLowerCase() == 'proses').toList();
      
      final laporanHilang = processReports.where((r) => r.jenisLaporan == 'hilang').toList();
      final laporanTemuan = processReports.where((r) => r.jenisLaporan == 'temuan').toList();
      
      List<Map<String, dynamic>> matches = [];
      
      // Lakukan pencocokan sederhana berdasarkan kesamaan nama barang dan lokasi
      for (final hilang in laporanHilang) {
        for (final temuan in laporanTemuan) {
          double score = _calculateSimpleScore(hilang, temuan);
          
          if (score >= 0.75) { // Threshold 75%
            matches.add({
              'laporanHilang': hilang,
              'laporanTemuan': temuan,
              'similarityScore': score,
            });
          }
        }
      }
      
      // Urutkan berdasarkan skor tertinggi
      matches.sort((a, b) => b['similarityScore'].compareTo(a['similarityScore']));
      
      setState(() {
        _isProcessingAutoMatch = false;
        _hasProcessedAutoMatch = true;
        _automaticMatches = matches;
      });
      
      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ditemukan pencocokan otomatis dengan threshold 75%'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ditemukan ${matches.length} pencocokan potensial'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingAutoMatch = false;
        _hasProcessedAutoMatch = true;
        _automaticMatches = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Fungsi untuk menghitung skor kesamaan sederhana
  double _calculateSimpleScore(Report hilang, Report temuan) {
    double score = 0.0;
    
    // Bandingkan nama barang (40% bobot)
    if (hilang.namaBarang.toLowerCase().contains(temuan.namaBarang.toLowerCase()) ||
        temuan.namaBarang.toLowerCase().contains(hilang.namaBarang.toLowerCase())) {
      score += 0.4;
    }
    
    // Bandingkan deskripsi (30% bobot)
    final hilangWords = hilang.deskripsi.toLowerCase().split(' ');
    final temuanWords = temuan.deskripsi.toLowerCase().split(' ');
    int commonWords = 0;
    
    for (final word in hilangWords) {
      if (temuanWords.contains(word) && word.length > 3) {
        commonWords++;
      }
    }
    
    if (hilangWords.isNotEmpty) {
      score += (commonWords / hilangWords.length) * 0.3;
    }
    
    // Bandingkan lokasi (30% bobot)
    if (hilang.lokasi.toLowerCase().contains(temuan.lokasi.toLowerCase()) ||
        temuan.lokasi.toLowerCase().contains(hilang.lokasi.toLowerCase())) {
      score += 0.3;
    }
    
    return score;
  }

  Future<void> _confirmMatch(Map<String, dynamic> match) async {
    final Report laporanHilang = match['laporanHilang'];
    final Report laporanTemuan = match['laporanTemuan'];
    final double score = match['similarityScore'];
    
    final result = await _matchingService.createMatching(
      laporanHilang.id,
      laporanTemuan.id,
      skorCocok: score * 100, // Convert to percentage
    );

    if (result['success'] == true) {
      // Kirim notifikasi kepada kedua user
      try {
        // Kirim notifikasi kepada user yang membuat laporan kehilangan
        await _notificationService.createStatusChangeNotification(
          userId: laporanHilang.userId,
          reportId: laporanHilang.id,
          reportName: laporanHilang.namaBarang,
          oldStatus: laporanHilang.status,
          newStatus: 'cocok',
        );
        
        // Kirim notifikasi kepada user yang membuat laporan temuan
        await _notificationService.createStatusChangeNotification(
          userId: laporanTemuan.userId,
          reportId: laporanTemuan.id,
          reportName: laporanTemuan.namaBarang,
          oldStatus: laporanTemuan.status,
          newStatus: 'cocok',
        );
        
        print('Notifikasi berhasil dikirim kepada kedua user');
      } catch (e) {
        print('Error mengirim notifikasi: $e');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pencocokan berhasil dikonfirmasi dan notifikasi telah dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh data
      _loadReports();
      _performAutomaticMatching();
      
      if (widget.onReportsUpdated != null) {
        widget.onReportsUpdated!();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Gagal mengkonfirmasi pencocokan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final Report laporanHilang = match['laporanHilang'];
    final Report laporanTemuan = match['laporanTemuan'];
    final double score = match['similarityScore'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: _getScoreColor(score),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(score * 100).toStringAsFixed(1)}% cocok',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _confirmMatch(match),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F41BB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Konfirmasi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lost item
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.search_off, size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Laporan Kehilangan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    laporanHilang.namaBarang,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    laporanHilang.deskripsi,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Lokasi: ${laporanHilang.lokasi}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Found item
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Laporan Temuan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    laporanTemuan.namaBarang,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    laporanTemuan.deskripsi,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Lokasi: ${laporanTemuan.lokasi}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.8) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildAutomaticTab() {
    if (_isProcessingAutoMatch) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses pencocokan otomatis...'),
          ],
        ),
      );
    }

    if (!_hasProcessedAutoMatch) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: const Color(0xFF1F41BB).withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Pencocokan Otomatis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gunakan AI untuk mencocokkan laporan\nhilang dan temuan secara otomatis',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _performAutomaticMatching,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(
                'Mulai Pencocokan Otomatis',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F41BB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_automaticMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak Ada Pencocokan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tidak ditemukan laporan yang cocok\ndengan threshold 75%',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _performAutomaticMatching,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F41BB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil Pencocokan AI',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Ditemukan ${_automaticMatches.length} pencocokan potensial',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _performAutomaticMatching,
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF1F41BB),
                ),
              ),
            ],
          ),
        ),
        // Matches list
        Expanded(
          child: ListView.builder(
            itemCount: _automaticMatches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(_automaticMatches[index]);
            },
          ),
        ),
      ],
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
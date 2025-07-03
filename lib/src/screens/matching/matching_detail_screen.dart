import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../widgets/report_detail_card.dart';

class MatchingDetailScreen extends StatefulWidget {
  final Report selectedReport;
  final List<Report> allReports;

  const MatchingDetailScreen({
    Key? key,
    required this.selectedReport,
    required this.allReports,
  }) : super(key: key);

  @override
  State<MatchingDetailScreen> createState() => _MatchingDetailScreenState();
}

class _MatchingDetailScreenState extends State<MatchingDetailScreen> {
  final ReportService _reportService = ReportService();

  List<Report> _matchingCandidates = [];

  @override
  void initState() {
    super.initState();
    _loadMatchingCandidates();
  }

  void _loadMatchingCandidates() {
    // Filter laporan yang bisa dicocokkan
    // Jika laporan yang dipilih adalah kehilangan, tampilkan laporan temuan
    // Jika laporan yang dipilih adalah temuan, tampilkan laporan kehilangan
    String targetType = widget.selectedReport.jenisLaporan == 'hilang'
         ? 'temuan'
         : 'hilang';

    setState(() {
      _matchingCandidates = widget.allReports
          .where((report) =>
              report.jenisLaporan == targetType &&
              report.status != 'Selesai' &&
              report.id != widget.selectedReport.id)
          .toList();
    });
  }

  Future<void> _showMatchConfirmation(Report matchingReport) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Pencocokan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah Anda yakin ingin mencocokkan kedua laporan ini?',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Laporan 1: ${widget.selectedReport.namaBarang}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Laporan 2: ${matchingReport.namaBarang}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kedua laporan akan ditandai sebagai "Cocok" dan tetap berada di beranda.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F41BB),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Cocokkan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _performMatching(matchingReport);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performMatching(Report matchingReport) async {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Tentukan mana laporan hilang dan mana laporan temuan
      String laporanHilangId;
      String laporanTemuanId;
      
      if (widget.selectedReport.jenisLaporan == 'hilang') {
        laporanHilangId = widget.selectedReport.id;
        laporanTemuanId = matchingReport.id;
      } else {
        laporanHilangId = matchingReport.id;
        laporanTemuanId = widget.selectedReport.id;
      }
      
      // Match kedua laporan menggunakan API
      final result = await _reportService.matchReports(
        laporanHilangId, 
        laporanTemuanId, 
        skorCocok: 85.0 // Default score
      );
      
      // Tutup loading indicator
      Navigator.of(context).pop();
      
      if (result['success'] == true) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Laporan berhasil dicocokkan dan notifikasi telah dikirim!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Kembali ke halaman sebelumnya dengan hasil true
        Navigator.of(context).pop(true);
      } else {
        // Tampilkan pesan error yang detail
        String errorMessage = result['error'] ?? 'Gagal mencocokkan laporan';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tutup',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Tutup loading indicator jika masih terbuka
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Pencocokan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F41BB),
          ),
        ),
      ),
      body: Column(
        children: [
          // Laporan yang dipilih (bagian atas)
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF1F41BB),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Laporan Terpilih',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F41BB),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ReportDetailCard(
                    report: widget.selectedReport,
                    showMatchButton: false,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 8,
            color: Colors.grey.shade100,
          ),
          
          // Laporan yang bisa dicocokkan (bagian bawah)
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kandidat Pencocokan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _matchingCandidates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada kandidat pencocokan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada laporan ${widget.selectedReport.jenisLaporan == 'hilang' ? 'temuan' : 'kehilangan'} yang tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _matchingCandidates.length,
                            itemBuilder: (context, index) {
                              final report = _matchingCandidates[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ReportDetailCard(
                                  report: report,
                                  showMatchButton: true,
                                  onMatchPressed: () => _showMatchConfirmation(report),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
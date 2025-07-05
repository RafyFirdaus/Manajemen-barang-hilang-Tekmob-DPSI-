import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/report_model.dart';
import '../models/klaim_model.dart';
import '../services/kategori_service.dart';
import '../services/lokasi_service.dart';
import 'fullscreen_image_viewer.dart';
import '../screens/klaim/klaim_form_screen.dart';

class ReportDetailModal extends StatefulWidget {
  final Report report;
  final bool showVerificationActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showClaimButton;
  final String? idLaporanCocok;
  final String? idPenerima;
  final Klaim? klaimData;
  final String? namaSatpam;

  const ReportDetailModal({
    Key? key,
    required this.report,
    this.showVerificationActions = false,
    this.onApprove,
    this.onReject,
    this.showClaimButton = false,
    this.idLaporanCocok,
    this.idPenerima,
    this.klaimData,
    this.namaSatpam,
  }) : super(key: key);

  @override
  State<ReportDetailModal> createState() => _ReportDetailModalState();

  static void show({
    required BuildContext context,
    required Report report,
    bool showVerificationActions = false,
    VoidCallback? onApprove,
    VoidCallback? onReject,
    bool showClaimButton = false,
    String? idLaporanCocok,
    String? idPenerima,
    Klaim? klaimData,
    String? namaSatpam,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailModal(
        report: report,
        showVerificationActions: showVerificationActions,
        onApprove: onApprove,
        onReject: onReject,
        showClaimButton: showClaimButton,
        idLaporanCocok: idLaporanCocok,
        idPenerima: idPenerima,
        klaimData: klaimData,
        namaSatpam: namaSatpam,
      ),
    );
  }

  static void showReportDetailModal({required BuildContext context, required Report report, required bool showVerificationActions}) {
    show(
      context: context,
      report: report,
      showVerificationActions: showVerificationActions,
    );
  }
}

class _ReportDetailModalState extends State<ReportDetailModal> with TickerProviderStateMixin {
  final KategoriService _kategoriService = KategoriService();
  final LokasiService _lokasiService = LokasiService();
  
  String? kategoriName;
  String? lokasiName;
  bool isLoadingKategori = false;
  bool isLoadingLokasi = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadKategoriAndLokasi();
    
    // Inisialisasi TabController hanya untuk laporan temuan yang selesai dengan klaim
    if (widget.report.jenisLaporan.toLowerCase() == 'temuan' && 
        widget.report.status.toLowerCase() == 'selesai' && 
        widget.klaimData != null) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadKategoriAndLokasi() async {
    // Load kategori name if kategoriId exists
    if (widget.report.kategoriId != null && widget.report.kategoriId!.isNotEmpty) {
      setState(() {
        isLoadingKategori = true;
      });
      
      try {
        final kategori = await _kategoriService.getKategoriById(widget.report.kategoriId!);
        if (mounted) {
          setState(() {
            kategoriName = kategori?.namaKategori;
            isLoadingKategori = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoadingKategori = false;
          });
        }
      }
    }

    // Load lokasi name if lokasiId exists
    if (widget.report.lokasiId != null && widget.report.lokasiId!.isNotEmpty) {
      setState(() {
        isLoadingLokasi = true;
      });
      
      try {
        final lokasi = await _lokasiService.getLokasiById(widget.report.lokasiId!);
        if (mounted) {
          setState(() {
            lokasiName = lokasi?.lokasiKlaim;
            isLoadingLokasi = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoadingLokasi = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    
    switch (widget.report.status.toLowerCase()) {
      case 'proses':
        break;
      case 'cocok':
        break;
      case 'selesai':
        break;
      default:
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _tabController != null 
                ? Column(
                    children: [
                      // Tab Bar untuk laporan temuan dengan klaim
                      Container(
                        margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFF1F41BB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Detail Laporan'),
                            Tab(text: 'Informasi Klaim'),
                          ],
                        ),
                      ),
                      // Tab Bar View
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Detail Laporan
                            SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildReportDetailContent(),
                            ),
                            // Tab 2: Informasi Klaim
                            SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildClaimInfoContent(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildReportDetailContent(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailContent() {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    
    Color statusColor;
    switch (widget.report.status.toLowerCase()) {
      case 'proses':
        statusColor = Colors.orange;
        break;
      case 'cocok':
        statusColor = Colors.green;
        break;
      case 'selesai':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto barang jika ada (dipindah ke atas)
        if (widget.report.fotoPaths.isNotEmpty) ...[
                    Text(
                      'Foto Barang (${widget.report.fotoPaths.length}):',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.report.fotoPaths.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (widget.report.fotoPaths[index].isNotEmpty) {
                                FullscreenImageViewer.show(
                                  context: context,
                                  imagePath: widget.report.fotoPaths[index],
                                  currentIndex: index,
                                  allImages: widget.report.fotoPaths,
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: widget.report.fotoPaths[index].isNotEmpty
                                    ? Stack(
                                        children: [
                                          _buildImageWidget(widget.report.fotoPaths[index]),
                                          // Overlay untuk menunjukkan bahwa foto dapat diklik
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Nama barang
                  Text(
                    widget.report.namaBarang,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tanggal kejadian
                  _buildDetailRow(
                    'Tanggal Kejadian:',
                    dateFormat.format(widget.report.tanggalKejadian),
                    Icons.calendar_today_outlined,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (widget.report.lokasiId != null && widget.report.lokasiId!.isNotEmpty)
                              Text(
                                isLoadingLokasi
                                    ? 'Memuat lokasi...'
                                    : (lokasiName ?? 'Lokasi tidak ditemukan'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              )
                            else
                              Text(
                                widget.report.lokasi,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lokasi Kejadian
                  if (widget.report.lokasi.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(    
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lokasi Kejadian:',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.report.lokasi.isNotEmpty
                                    ? widget.report.lokasi
                                    : 'Lokasi kejadian tidak tersedia',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Kategori
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.category,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoadingKategori
                                  ? 'Memuat kategori...'
                                  : (kategoriName ?? 'Kategori tidak ditemukan'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Deskripsi barang
                  Text(
                    'Deskripsi Barang:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.report.deskripsi,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status dan jenis laporan
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.report.jenisLaporan == 'hilang' 
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.report.jenisLaporan,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: widget.report.jenisLaporan == 'hilang' 
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Status: ${widget.report.status}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tanggal dibuat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Dibuat: ${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(widget.report.tanggalDibuat)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

  // Action button untuk menandai ditemukan (hanya untuk satpam)
  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.showVerificationActions) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApprove?.call(); // Menggunakan onApprove untuk menghapus laporan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tandai Ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Tombol Klaim Barang (hanya untuk satpam, laporan temuan, dan status cocok)
        if (widget.showClaimButton && 
            widget.report.jenisLaporan == 'temuan' &&
            widget.report.status.toLowerCase() == 'cocok' && 
            widget.idLaporanCocok != null && 
            widget.idPenerima != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KlaimFormScreen(
                      matchedReport: widget.report,
                      idLaporanCocok: widget.idLaporanCocok!,
                      idPenerima: widget.idPenerima!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F41BB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Klaim Barang',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildClaimInfoContent() {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    
    if (widget.klaimData == null) {
      return Center(
        child: Text(
          'Informasi klaim tidak tersedia',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Klaim',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Nama Satpam
              _buildDetailRow(
                'Diklaim oleh:',
                widget.namaSatpam ?? 'Satpam',
                Icons.person,
              ),
              const SizedBox(height: 12),
              
              // Waktu Klaim
              _buildDetailRow(
                'Waktu Klaim:',
                '${dateFormat.format(widget.klaimData!.waktuTerima)} ${timeFormat.format(widget.klaimData!.waktuTerima)}',
                Icons.access_time,
              ),
              
              // Bukti Foto Klaim
              if (widget.klaimData!.urlFotoKlaim != null && widget.klaimData!.urlFotoKlaim!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Bukti Foto Klaim:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    FullscreenImageViewer.show(
                      context: context,
                      imagePath: widget.klaimData!.urlFotoKlaim!,
                      currentIndex: 0,
                      allImages: [widget.klaimData!.urlFotoKlaim!],
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          _buildImageWidget(widget.klaimData!.urlFotoKlaim!),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath) {
    try {
      // Check if it's a base64 encoded image
      if (imagePath.startsWith('data:image')) {
        // Extract base64 data from data URL
        final base64Data = imagePath.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
        );
      } else {
        // Fallback for network images or other formats
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // Error handling
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Colors.grey,
        ),
      );
    }
  }
}
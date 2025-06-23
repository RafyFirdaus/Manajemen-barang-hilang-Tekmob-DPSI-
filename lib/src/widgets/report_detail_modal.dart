import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/report_model.dart';
import 'fullscreen_image_viewer.dart';

class ReportDetailModal extends StatelessWidget {
  final Report report;
  final bool showVerificationActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ReportDetailModal({
    Key? key,
    required this.report,
    this.showVerificationActions = false,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required Report report,
    bool showVerificationActions = false,
    VoidCallback? onApprove,
    VoidCallback? onReject,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    
    Color statusColor;
    switch (report.status.toLowerCase()) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto barang jika ada (dipindah ke atas)
                  if (report.fotoPaths.isNotEmpty) ...[
                    Text(
                      'Foto Barang (${report.fotoPaths.length}):',
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
                        itemCount: report.fotoPaths.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (report.fotoPaths[index].isNotEmpty) {
                                FullscreenImageViewer.show(
                                  context: context,
                                  imagePath: report.fotoPaths[index],
                                  currentIndex: index,
                                  allImages: report.fotoPaths,
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
                                child: report.fotoPaths[index].isNotEmpty
                                    ? Stack(
                                        children: [
                                          _buildImageWidget(report.fotoPaths[index]),
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
                    report.namaBarang,
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
                    dateFormat.format(report.tanggalKejadian),
                    Icons.calendar_today_outlined,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lokasi
                  _buildDetailRow(
                    'Lokasi:',
                    report.lokasi,
                    Icons.location_on_outlined,
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
                      report.deskripsi,
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
                          color: report.jenisLaporan == 'Laporan Kehilangan' 
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.jenisLaporan,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: report.jenisLaporan == 'Laporan Kehilangan' 
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
                          'Status: ${report.status}',
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
                      'Dibuat: ${dateFormat.format(report.tanggalDibuat)} ${timeFormat.format(report.tanggalDibuat)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol Klaim Barang untuk laporan temuan (hanya untuk user)
                  if (report.jenisLaporan == 'Laporan Temuan' && !showVerificationActions) ...[                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implementasi fungsi klaim barang
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur klaim barang akan segera tersedia'),
                              backgroundColor: Colors.blue,
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
                        child: Text(
                          'Klaim Barang',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Action button untuk menandai ditemukan (hanya untuk satpam)
                  if (showVerificationActions) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onApprove?.call(); // Menggunakan onApprove untuk menghapus laporan
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
                ],
              ),
            ),
          ),
        ],
      ),
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
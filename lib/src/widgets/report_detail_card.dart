import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/report_model.dart';
import '../services/kategori_service.dart';
import '../services/lokasi_service.dart';
import 'fullscreen_image_viewer.dart';

class ReportDetailCard extends StatefulWidget {
  final Report report;
  final bool showMatchButton;
  final VoidCallback? onMatchPressed;

  const ReportDetailCard({
    Key? key,
    required this.report,
    this.showMatchButton = false,
    this.onMatchPressed,
  }) : super(key: key);

  @override
  State<ReportDetailCard> createState() => _ReportDetailCardState();
}

class _ReportDetailCardState extends State<ReportDetailCard> {
  final KategoriService _kategoriService = KategoriService();
  final LokasiService _lokasiService = LokasiService();
  
  String? kategoriName;
  String? lokasiName;
  bool isLoadingKategori = false;
  bool isLoadingLokasi = false;

  @override
  void initState() {
    super.initState();
    _loadKategoriAndLokasi();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan jenis laporan dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.report.jenisLaporan == 'hilang' 
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.report.jenisLaporan == 'hilang' 
                          ? 'Barang Hilang'
                          : 'Barang Temuan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.report.jenisLaporan == 'hilang' 
                           ? Colors.red
                           : Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.report.status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(widget.report.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Nama barang
            Text(
              widget.report.namaBarang,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Kategori
            if (widget.report.kategoriId != null && widget.report.kategoriId!.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: isLoadingKategori
                        ? Text(
                            'Memuat kategori...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Text(
                            kategoriName ?? 'Kategori tidak ditemukan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            if (widget.report.kategoriId != null && widget.report.kategoriId!.isNotEmpty)
              const SizedBox(height: 4),
            
            // Deskripsi
            Text(
              widget.report.deskripsi,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Lokasi kejadian
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.report.lokasi,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Lokasi klaim
            if (widget.report.lokasiId != null && widget.report.lokasiId!.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: isLoadingLokasi
                        ? Text(
                            'Memuat lokasi klaim...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Text(
                            lokasiName ?? 'Lokasi klaim tidak ditemukan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            if (widget.report.lokasiId != null && widget.report.lokasiId!.isNotEmpty)
              const SizedBox(height: 4),
            
            // Tanggal
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(widget.report.tanggalKejadian),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            // Foto jika ada
            if (widget.report.fotoPaths.isNotEmpty)
              const SizedBox(height: 12),
            if (widget.report.fotoPaths.isNotEmpty)
              GestureDetector(
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    imagePath: widget.report.fotoPaths.first,
                    currentIndex: 0,
                    allImages: widget.report.fotoPaths,
                  );
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(widget.report.fotoPaths.first),
                      ),
                      // Overlay untuk menunjukkan bahwa foto dapat diklik
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                      // Badge untuk multiple images
                      if (widget.report.fotoPaths.length > 1)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${widget.report.fotoPaths.length - 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
            // Tombol cocok jika diperlukan
            if (widget.showMatchButton)
              const SizedBox(height: 16),
            if (widget.showMatchButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onMatchPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F41BB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cocokkan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
        );
      } else {
        // Handle network images
        String imageUrl = imagePath;
        
        // If it's a relative path, prepend the base URL
        if (!imagePath.startsWith('http')) {
          const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app';
          imageUrl = '$baseUrl$imagePath';
        }
        
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
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
              color: Colors.grey.shade200,
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
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Colors.grey,
        ),
      );
    }
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../services/klaim_service.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../dashboard/satpam_dashboard_screen.dart';

class KlaimFormScreen extends StatefulWidget {
  final Report matchedReport;
  final String idLaporanCocok;
  final String idPenerima;

  const KlaimFormScreen({
    Key? key,
    required this.matchedReport,
    required this.idLaporanCocok,
    required this.idPenerima,
  }) : super(key: key);

  @override
  State<KlaimFormScreen> createState() => _KlaimFormScreenState();
}

class _KlaimFormScreenState extends State<KlaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalLaporanController = TextEditingController();
  
  File? _fotoKlaim;
  String _usernamePembuat = '';
  
  bool _isSubmitting = false;
  bool _isLoadingUserData = false;
  
  final ImagePicker _picker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  final ReportService _reportService = ReportService();
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadUsernamePembuat();
  }
  
  void _initializeData() {
    // Set tanggal laporan dibuat
    _tanggalLaporanController.text = _dateFormat.format(widget.matchedReport.tanggalDibuat);
  }
  
  Future<void> _loadUsernamePembuat() async {
    setState(() {
      _isLoadingUserData = true;
    });
    
    try {
      // Ambil data cocok berdasarkan laporan temuan ini
      final cocokData = await _reportService.getCocokByReportId(widget.matchedReport.id);
      
      if (cocokData != null) {
        // Ambil ID laporan hilang dari data cocok
        final idLaporanHilang = cocokData['id_laporan_hilang'];
        
        if (idLaporanHilang != null) {
          // Ambil data laporan hilang
          final laporanHilang = await _reportService.getReportById(idLaporanHilang);
          
          if (laporanHilang != null) {
            // Ambil data user berdasarkan userId dari laporan hilang
            final userData = await _authService.getUserById(laporanHilang.userId);
            
            setState(() {
              if (userData != null && userData['username'] != null) {
                _usernamePembuat = userData['username'];
              } else {
                _usernamePembuat = 'User ID: ${laporanHilang.userId}';
              }
              _isLoadingUserData = false;
            });
            return;
          }
        }
      }
      
      // Jika gagal mendapatkan data cocok, gunakan idPenerima sebagai fallback
      throw Exception('Data cocok tidak ditemukan');
      
    } catch (e) {
      // Fallback: gunakan idPenerima jika gagal mencari laporan hilang
      try {
        final userData = await _authService.getUserById(widget.idPenerima);
        setState(() {
          if (userData != null && userData['username'] != null) {
            _usernamePembuat = userData['username'];
          } else {
            _usernamePembuat = 'User ID: ${widget.idPenerima}';
          }
          _isLoadingUserData = false;
        });
      } catch (fallbackError) {
        setState(() {
          _usernamePembuat = 'User ID: ${widget.idPenerima}';
          _isLoadingUserData = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat data pembuat laporan: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
  
  

  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _fotoKlaim = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: $e');
    }
  }
  
  Future<void> _submitKlaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_fotoKlaim == null) {
      _showErrorSnackBar('Ambil foto bukti klaim');
      return;
    }
    
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final klaimService = KlaimService();
      final result = await klaimService.submitKlaim(
        idLaporanCocok: widget.idLaporanCocok,
        idPenerima: widget.idPenerima,
        fotoKlaim: _fotoKlaim,
      );
      
      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Gagal submit klaim');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Klaim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengklaim barang ini? Status laporan akan berubah menjadi selesai.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F41BB),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Ya, Klaim',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Berhasil',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Klaim barang berhasil disubmit. Status laporan telah berubah menjadi selesai.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Navigate back to Satpam Dashboard and set to "Riwayat Selesai" tab
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SatpamDashboardScreen(initialTabIndex: 1),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Form Klaim Barang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1F41BB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info barang
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F41BB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1F41BB).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Barang',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F41BB),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                             widget.matchedReport.namaBarang,
                             style: GoogleFonts.poppins(
                               fontSize: 18,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             widget.matchedReport.deskripsi,
                             style: GoogleFonts.poppins(
                               fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Username Pembuat Laporan Hilang
                    Text(
                      'Pembuat Laporan Hilang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: _isLoadingUserData
                          ? Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Memuat data pembuat laporan...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _usernamePembuat.isNotEmpty ? _usernamePembuat : 'Data tidak tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tanggal Laporan
                    Text(
                      'Tanggal Laporan Dibuat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tanggalLaporanController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    

                    
                    const SizedBox(height: 20),
                    
                    // Foto Bukti Klaim
                    Text(
                      'Foto Bukti Klaim',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _fotoKlaim != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _fotoKlaim!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap untuk mengambil foto',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Foto bukti klaim barang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitKlaim,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F41BB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      'Memproses...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Submit Klaim',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    _tanggalLaporanController.dispose();
    super.dispose();
  }
}
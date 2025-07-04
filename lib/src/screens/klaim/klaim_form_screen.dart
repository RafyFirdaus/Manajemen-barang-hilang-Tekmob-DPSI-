import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../models/kategori_model.dart';
import '../../models/lokasi_model.dart';
import '../../services/klaim_service.dart';
import '../../services/lokasi_service.dart';
import '../../services/kategori_service.dart';
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
  final _namaPelaporController = TextEditingController();
  final _tanggalLaporanController = TextEditingController();
  
  String? _selectedLokasiId;
  String? _selectedKategoriId;
  File? _fotoKlaim;
  
  List<Lokasi> _lokasiList = [];
  List<Kategori> _kategoriList = [];
  
  bool _isLoadingKategori = false;
  bool _isLoadingLokasi = false;
  bool _isSubmitting = false;
  
  final ImagePicker _picker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  
  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadKategoriData();
    _loadLokasiData();
  }
  
  void _initializeData() {
    // Set data dari laporan yang cocok
    _namaPelaporController.text = ''; // Ini perlu diambil dari user data
    
    // Pastikan tanggalDibuat tidak null
    _tanggalLaporanController.text = _dateFormat.format(widget.matchedReport.tanggalDibuat);
    }
  
  
  Future<void> _loadKategoriData() async {
    setState(() {
      _isLoadingKategori = true;
    });
    
    try {
      final kategoriService = KategoriService();
      final kategoriList = await kategoriService.getAllKategori();
      setState(() {
        _kategoriList = kategoriList;
        _isLoadingKategori = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingKategori = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data kategori: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadLokasiData() async {
    setState(() {
      _isLoadingLokasi = true;
    });
    
    try {
      final lokasiService = LokasiService();
      final lokasiList = await lokasiService.getAllLokasi();
      setState(() {
        _lokasiList = lokasiList;
        _isLoadingLokasi = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLokasi = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data lokasi: $e'),
            backgroundColor: Colors.orange,
          ),
        );
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
    
    if (_selectedLokasiId == null) {
      _showErrorSnackBar('Pilih lokasi kehilangan');
      return;
    }
    
    if (_selectedKategoriId == null) {
      _showErrorSnackBar('Pilih kategori barang');
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
                    
                    // Nama Pelapor
                    Text(
                      'Nama Pelapor',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaPelaporController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama pelapor',
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: const Color(0xFF1F41BB),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pelapor wajib diisi';
                        }
                        return null;
                      },
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
                    
                    // Lokasi Kehilangan
                    Text(
                      'Lokasi Klaim',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingLokasi
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Memuat lokasi...'),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLokasiId,
                                hint: Text(
                                  'Pilih lokasi klaim',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                                isExpanded: true,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                items: _lokasiList.map((Lokasi lokasi) {
                                  return DropdownMenuItem<String>(
                                    value: lokasi.idLokasiKlaim,
                                    child: Text(lokasi.lokasiKlaim),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedLokasiId = newValue;
                                  });
                                },
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Kategori Barang
                    Text(
                      'Kategori Barang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingKategori
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Memuat kategori...'),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKategoriId,
                                hint: Text(
                                  'Pilih Kategori',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                                isExpanded: true,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                items: _kategoriList.map((Kategori kategori) {
                                  return DropdownMenuItem<String>(
                                    value: kategori.idKategori,
                                    child: Text(kategori.namaKategori),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedKategoriId = newValue;
                                  });
                                },
                              ),
                            ),
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
    _namaPelaporController.dispose();
    _tanggalLaporanController.dispose();
    super.dispose();
  }
}
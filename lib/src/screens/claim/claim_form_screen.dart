import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../models/kategori_model.dart';
import '../../models/lokasi_model.dart';
import '../../services/report_service.dart';
import '../../services/kategori_service.dart';
import '../../services/lokasi_service.dart';


class ClaimFormScreen extends StatefulWidget {
  final Report report;

  const ClaimFormScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaPelaporController = TextEditingController();
  final _tanggalKehilanganController = TextEditingController();
  final _lokasiKehilanganController = TextEditingController();
  final _kategoriBarangController = TextEditingController();
  final ReportService _reportService = ReportService();
  final KategoriService _kategoriService = KategoriService();
  final LokasiService _lokasiService = LokasiService();

  bool _isLoading = false;
  
  // New fields for kategori and lokasi
  List<Kategori> _kategoriList = [];
  List<Lokasi> _lokasiList = [];
  String? _selectedKategoriId;
  String? _selectedLokasiId;
  bool _isLoadingKategori = false;
  bool _isLoadingLokasi = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form dengan data dari laporan
    _tanggalKehilanganController.text = DateFormat('dd/MM/yyyy').format(widget.report.tanggalKejadian);
    _lokasiKehilanganController.text = widget.report.lokasi;
    _kategoriBarangController.text = widget.report.namaBarang;
    
    // Load kategori and lokasi data
    _loadKategoriData();
    _loadLokasiData();
    
    // Set selected values if available
    _selectedKategoriId = widget.report.kategoriId;
    _selectedLokasiId = widget.report.lokasiId;
  }
  
  Future<void> _loadKategoriData() async {
    setState(() {
      _isLoadingKategori = true;
    });
    
    try {
      final kategoriList = await _kategoriService.getAllKategori();
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
            backgroundColor: Colors.red,
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
      final lokasiList = await _lokasiService.getAllLokasi();
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaPelaporController.dispose();
    _tanggalKehilanganController.dispose();
    _lokasiKehilanganController.dispose();
    _kategoriBarangController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Klaim barang - update kedua laporan yang cocok menjadi 'Selesai'
      await _reportService.claimMatchedReports(widget.report.id);
      

      
      if (mounted) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Klaim berhasil disubmit! Status laporan telah diubah menjadi selesai.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Kembali ke dashboard
        Navigator.pop(context, true); // Return true untuk menandakan perlu refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal submit klaim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          'Form Klaim Barang',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info barang
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
                      'Barang yang akan diklaim:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F41BB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.report.namaBarang,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
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
                  hintText: 'Masukkan nama lengkap Anda',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pelapor harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Tanggal Kehilangan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tanggalKehilanganController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal kehilangan',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1F41BB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: widget.report.tanggalKejadian,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _tanggalKehilanganController.text = DateFormat('dd/MM/yyyy').format(picked);
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal kehilangan harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Lokasi Kehilangan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiKehilanganController,
                decoration: InputDecoration(
                  hintText: 'Masukkan lokasi kehilangan',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi kehilangan harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Kategori Barang',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingKategori
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedKategoriId,
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori barang',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _kategoriList.map((kategori) {
                        return DropdownMenuItem<String>(
                          value: kategori.idKategori,
                          child: Text(
                            kategori.namaKategori,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKategoriId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori barang harus dipilih';
                        }
                        return null;
                      },
                    ),
              
              const SizedBox(height: 20),
              
              Text(
                'Lokasi Klaim',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingLokasi
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedLokasiId,
                      decoration: InputDecoration(
                        hintText: 'Pilih lokasi klaim',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1F41BB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _lokasiList.map((lokasi) {
                        return DropdownMenuItem<String>(
                          value: lokasi.idLokasiKlaim,
                          child: Text(
                            lokasi.lokasiKlaim,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLokasiId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi klaim harus dipilih';
                        }
                        return null;
                      },
                    ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F41BB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
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
}
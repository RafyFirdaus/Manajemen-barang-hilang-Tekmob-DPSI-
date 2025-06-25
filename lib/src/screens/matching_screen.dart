import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  // Dropdown values
  String _jenisMatching = 'Manual';
  String _kategoriBarang = 'Barang Hilang';
  DateTime? _tanggal;
  String _lokasi = 'Gedung Utama';
  
  // Options for dropdowns
  final List<String> _jenisMatchingOptions = ['Manual', 'Otomatis'];
  final List<String> _kategoriBarangOptions = ['Barang Hilang', 'Barang Temuan'];
  final List<String> _lokasiOptions = ['Gedung Utama', 'Gedung Lab', 'Masjid Islamic Center'];
  
  final ReportService _reportService = ReportService();
  bool _isLoading = false;
  List<Report> _matchedReports = [];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1F41BB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  Future<void> _findMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implementasi logika pencocokan
      // Untuk saat ini, hanya menampilkan semua laporan yang sesuai dengan filter
      final reports = await _reportService.getAllReports();
      
      // Filter berdasarkan kategori barang
      final filteredByCategory = reports.where((report) {
        if (_kategoriBarang == 'Barang Hilang') {
          return report.jenisLaporan == 'Laporan Kehilangan';
        } else {
          return report.jenisLaporan == 'Laporan Temuan';
        }
      }).toList();
      
      // Filter berdasarkan lokasi
      final filteredByLocation = filteredByCategory.where((report) {
        return report.lokasi.contains(_lokasi);
      }).toList();
      
      // Filter berdasarkan tanggal jika dipilih
      final filtered = _tanggal != null 
          ? filteredByLocation.where((report) {
              return report.tanggalKejadian.year == _tanggal!.year &&
                     report.tanggalKejadian.month == _tanggal!.month &&
                     report.tanggalKejadian.day == _tanggal!.day;
            }).toList()
          : filteredByLocation;
      
      setState(() {
        _matchedReports = filtered;
        _isLoading = false;
      });
      
      // Tampilkan pesan jika tidak ada hasil
      if (_matchedReports.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ditemukan laporan yang cocok dengan kriteria'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencari kecocokan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis Matching Dropdown
            Text(
              'Jenis Pencocokan',
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jenisMatching,
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  items: _jenisMatchingOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _jenisMatching = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Kategori Barang Dropdown
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _kategoriBarang,
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  items: _kategoriBarangOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _kategoriBarang = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tanggal Field
            Text(
              'Tanggal',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tanggal == null
                          ? 'Pilih Tanggal'
                          : '${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _tanggal == null ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF1F41BB)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Lokasi Dropdown
            Text(
              'Lokasi',
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _lokasi,
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  items: _lokasiOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _lokasi = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Cari Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _findMatches,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F41BB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Cari Kecocokan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Results Section
            if (_matchedReports.isNotEmpty) ...[  
              Text(
                'Hasil Pencocokan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _matchedReports.length,
                itemBuilder: (context, index) {
                  final report = _matchedReports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        report.namaBarang,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            report.jenisLaporan,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: report.jenisLaporan == 'Laporan Kehilangan' 
                                  ? Colors.red.shade700 
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lokasi: ${report.lokasi}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanggal: ${report.tanggalKejadian.day}/${report.tanggalKejadian.month}/${report.tanggalKejadian.year}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Tampilkan detail laporan
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
  }
}
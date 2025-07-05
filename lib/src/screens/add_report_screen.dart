import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/report_model.dart';
import '../models/kategori_model.dart';
import '../models/lokasi_model.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';
import '../services/kategori_service.dart';
import '../services/lokasi_service.dart';
import 'dart:math';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({Key? key}) : super(key: key);

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaBarangController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String _jenisLaporan = 'hilang';
  DateTime? _tanggalKejadian;
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final ReportService _reportService = ReportService();
  final AuthService _authService = AuthService();
  final KategoriService _kategoriService = KategoriService();
  final LokasiService _lokasiService = LokasiService();
  TabController? _tabController;
  String _userRole = '';
  
  // New fields for kategori and lokasi
  List<Kategori> _kategoriList = [];
  List<Lokasi> _lokasiList = [];
  String? _selectedKategoriId;
  String? _selectedLokasiId;
  bool _isLoadingKategori = false;
  bool _isLoadingLokasi = false;
  
  // Safe reference untuk ScaffoldMessenger
  ScaffoldMessengerState? _scaffoldMessenger;
  
  // Method untuk mendapatkan default lokasi klaim
  String? _getDefaultLokasiKlaim() {
    if (_jenisLaporan == 'hilang') {
      // Pilih lokasi pertama dari list sebagai default
      if (_lokasiList.isNotEmpty) {
        return _lokasiList.first.idLokasiKlaim;
      } else {
        // Fallback ke ID default jika list kosong
        return 'default_location_id';
      }
    }
    return _selectedLokasiId;
  }

  void _onJenisLaporanChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _jenisLaporan = newValue;
        // Auto-select default lokasi untuk laporan hilang
        if (newValue == 'hilang') {
          _selectedLokasiId = _getDefaultLokasiKlaim();
        } else {
          _selectedLokasiId = null;
        }
      });
    }
  }

  final List<String> _jenisLaporanOptions = [
    'hilang',
    'temuan',
  ];

  // Helper function to get display text for jenis laporan
  String _getJenisLaporanDisplayText(String value) {
    switch (value) {
      case 'hilang':
        return 'Laporan Kehilangan';
      case 'temuan':
        return 'Laporan Temuan';
      default:
        return value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Simpan referensi yang aman untuk ScaffoldMessenger
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi TabController dengan default value untuk mencegah crash
    _tabController = TabController(length: 1, vsync: this);
    
    // Error handling untuk mencegah crash - tanpa setState
    FlutterError.onError = (FlutterErrorDetails details) {
      print('Flutter Error: ${details.exception}');
      // Tidak menggunakan setState di sini untuk menghindari crash
      _isLoading = false;
    };
    
    // Gunakan scheduleMicrotask untuk semua operasi async
    scheduleMicrotask(() {
      _loadUserRole();
      _loadKategoriData();
      _loadLokasiData();
      
      // Set default lokasi untuk jenis laporan default (hilang)
      if (_jenisLaporan == 'hilang' && mounted) {
        setState(() {
          _selectedLokasiId = _getDefaultLokasiKlaim();
        });
      }
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final userData = await _authService.getUserData();
      final newRole = userData['role'] ?? '';
      final newLength = newRole == 'satpam' ? 2 : 1;
      
      if (mounted) {
        // Dispose TabController lama di luar setState
        final oldController = _tabController;
        final newController = TabController(length: newLength, vsync: this);
        
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _userRole = newRole;
              _tabController = newController;
            });
            // Dispose controller lama setelah setState selesai
            oldController?.dispose();
          } else {
            // Jika widget sudah tidak mounted, dispose controller baru
            newController.dispose();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Dispose TabController lama di luar setState
        final oldController = _tabController;
        final newController = TabController(length: 1, vsync: this);
        
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _userRole = '';
              _tabController = newController;
            });
            // Dispose controller lama setelah setState selesai
            oldController?.dispose();
          } else {
            // Jika widget sudah tidak mounted, dispose controller baru
            newController.dispose();
          }
        });
      }
    }
  }

  Future<void> _loadKategoriData() async {
    if (mounted) {
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _isLoadingKategori = true;
          });
        }
      });
    }
    
    try {
      final kategoriList = await _kategoriService.getAllKategori();
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _kategoriList = kategoriList;
              _isLoadingKategori = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _isLoadingKategori = false;
            });
            _scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Gagal memuat data kategori: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _loadLokasiData() async {
    if (mounted) {
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _isLoadingLokasi = true;
          });
        }
      });
    }
    
    try {
      final lokasiList = await _lokasiService.getAllLokasi();
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _lokasiList = lokasiList;
              _isLoadingLokasi = false;
              // Set default lokasi setelah data dimuat jika jenis laporan adalah hilang
              if (_jenisLaporan == 'hilang' && _selectedLokasiId == null) {
                _selectedLokasiId = _getDefaultLokasiKlaim();
              }
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _isLoadingLokasi = false;
            });
            _scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Gagal memuat data lokasi: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    // Dispose TabController dengan null safety
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKejadian ?? DateTime.now(),
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
    if (picked != null && picked != _tanggalKejadian && mounted) {
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _tanggalKejadian = picked;
          });
        }
      });
    }
  }

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (images.isNotEmpty && mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _selectedImages.addAll(images);
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            _scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Gagal memilih gambar dari galeri: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _selectedImages.add(image);
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            _scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Gagal mengambil foto: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _selectedImages.removeAt(index);
          });
        }
      });
    }
  }

  void _resetForm() {
    if (mounted) {
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            // Reset semua field form
            _namaBarangController.clear();
            _lokasiController.clear();
            _deskripsiController.clear();
            _jenisLaporan = 'hilang';
            _tanggalKejadian = null;
            _selectedImages.clear();
            _selectedKategoriId = null;
            _selectedLokasiId = _jenisLaporan == 'hilang' ? _getDefaultLokasiKlaim() : null;
          });
        }
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedKategoriId == null) {
      _scaffoldMessenger?.showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori barang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi lokasi klaim hanya untuk laporan temuan
    if (_jenisLaporan == 'temuan' && _selectedLokasiId == null) {
      _scaffoldMessenger?.showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih lokasi klaim untuk laporan temuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Pastikan laporan hilang memiliki lokasi default
    if (_jenisLaporan == 'hilang' && _selectedLokasiId == null) {
      _selectedLokasiId = _getDefaultLokasiKlaim();
    }

    if (_tanggalKejadian == null) {
      _scaffoldMessenger?.showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal kejadian'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    
    try {
      // Set loading state dengan scheduleMicrotask
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }
      });
      
      // Pastikan UI ter-render sebelum melanjutkan
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Generate unique ID for report
      final reportId = 'RPT_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      // Get current user info dengan timeout
      final userData = await _authService.getUserData().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout getting user data', const Duration(seconds: 10)),
      );
      final userId = userData['id'] ?? 'unknown';
      
      // Buat objek Report tanpa foto terlebih dahulu
      final report = Report(
        id: reportId,
        jenisLaporan: _jenisLaporan,
        namaBarang: _namaBarangController.text,
        lokasi: _lokasiController.text,
        kategoriId: _selectedKategoriId,
        // Set lokasiId: untuk temuan gunakan pilihan user, untuk hilang gunakan default
        lokasiId: _jenisLaporan == 'temuan' ? _selectedLokasiId : _getDefaultLokasiKlaim(),
        tanggalKejadian: _tanggalKejadian!,
        deskripsi: _deskripsiController.text,
        fotoPaths: [], // Kosong karena foto akan diupload langsung di saveReport
        tanggalDibuat: DateTime.now(),
        status: 'proses',
        userId: userId,
      );
      
      // Save report dengan foto yang akan diupload langsung dengan timeout
      final success = await _reportService.saveReport(report, photos: _selectedImages).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          return false;
        },
      );
      
      if (!mounted) return;
      
      // Reset loading state dengan scheduleMicrotask
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      
      if (success) {
        // Reset form setelah berhasil submit
        _resetForm();
        
        // Tampilkan success message
        _scaffoldMessenger?.showSnackBar(
          SnackBar(
            content: Text('$_jenisLaporan berhasil dikirim'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Tidak melakukan Navigator.pop karena screen ini adalah bagian dari IndexedStack
        // User akan tetap di screen yang sama dan bisa membuat laporan baru
      } else {
        throw Exception('Gagal menyimpan laporan - Server tidak merespons');
      }
    } on TimeoutException {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _scaffoldMessenger?.showSnackBar(
              const SnackBar(
                content: Text('Koneksi timeout. Silakan coba lagi.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _scaffoldMessenger?.showSnackBar(
              SnackBar(
                content: Text('Gagal mengirim laporan: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
        toolbarHeight: 0,
        bottom: _userRole.isNotEmpty && _tabController != null ? TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1F41BB),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF1F41BB),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: _userRole == 'satpam' 
            ? const [
                Tab(text: 'Tambah Laporan'),
                Tab(text: 'Pencocokan'),
              ]
            : const [
                Tab(text: 'Tambah Laporan'),
              ],
        ) : null,
      ),
      body: Stack(
        children: [
          // Pastikan TabController sudah diinisialisasi
          _tabController != null 
            ? TabBarView(
                controller: _tabController,
                children: _userRole == 'satpam'
                  ? [
                      _buildAddReportTab(),
                      _buildMatchingTab(),
                    ]
                  : [
                      _buildAddReportTab(),
                    ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
          // Loading overlay yang diperbaiki
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mengirim laporan...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mohon tunggu sebentar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddReportTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jenis Laporan Dropdown
              Text(
                'Jenis Laporan',
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
                    value: _jenisLaporan,
                    isExpanded: true,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    items: _jenisLaporanOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_getJenisLaporanDisplayText(value)),
                      );
                    }).toList(),
                    onChanged: _onJenisLaporanChanged,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nama Barang
              Text(
                'Nama Barang',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaBarangController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama barang',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
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
                  if (value == null || value.isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
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

              // Lokasi Klaim (hanya untuk laporan temuan)
              if (_jenisLaporan == 'temuan') ...[
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
              ],

              // Lokasi Kejadian
              Text(
                'Lokasi Kejadian',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  hintText: _jenisLaporan == 'hilang'
                      ? 'Masukkan lokasi kejadian kehilangan'
                      : 'Masukkan lokasi kejadian penemuan',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
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
                  if (value == null || value.isEmpty) {
                    return 'Lokasi kejadian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tanggal Kejadian
              Text(
                'Tanggal Kejadian',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tanggalKejadian != null
                            ? '${_tanggalKejadian!.day}/${_tanggalKejadian!.month}/${_tanggalKejadian!.year}'
                            : 'Pilih Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _tanggalKejadian != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Deskripsi
              Text(
                'Deskripsi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan Deskripsi',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
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
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Upload Foto
              Text(
                'Upload Foto',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk upload foto',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                      future: _selectedImages[index].readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
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
                          'Kirim Laporan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildMatchingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Fitur Pencocokan',
            style: GoogleFonts.poppins(
              fontSize: 20,
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
}
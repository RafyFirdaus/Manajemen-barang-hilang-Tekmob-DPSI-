import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  
  const ProfileScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  String _username = '';
  String _email = '';
  String _role = '';
  String _urlFotoIdentitas = '';
  String _phone = '';
  
  // Controllers for edit profile
  final _editUsernameController = TextEditingController();
  final _editPhoneController = TextEditingController();
  File? _selectedProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _editUsernameController.dispose();
    _editPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getFullUserData();
      if (mounted) {
        setState(() {
          _username = userData['username'] ?? 'User';
          _email = userData['email'] ?? '';
          _role = userData['role'] ?? widget.role;
          _urlFotoIdentitas = userData['url_foto_identitas'] ?? '';
          _phone = userData['phone'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data profil: $e')),
        );
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F41BB),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  Future<void> _showEditProfileDialog() async {
    // Initialize controllers with current data
    _editUsernameController.text = _username;
    _editPhoneController.text = _phone;
    _selectedProfileImage = null;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F41BB),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Photo Section
                    GestureDetector(
                      onTap: () => _pickProfileImage(setState),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1F41BB),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _selectedProfileImage != null
                              ? Image.file(
                                  _selectedProfileImage!,
                                  fit: BoxFit.cover,
                                )
                              : _urlFotoIdentitas.isNotEmpty
                                  ? Image.network(
                                      _urlFotoIdentitas,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildEditDefaultAvatar();
                                      },
                                    )
                                  : _buildEditDefaultAvatar(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap untuk mengubah foto',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Username Field
                    TextField(
                      controller: _editUsernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF1F41BB),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1F41BB),
                            width: 2,
                          ),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email tidak dapat diubah melalui endpoint profil
                    
                    // Phone Field
                    TextField(
                      controller: _editPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF1F41BB),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1F41BB),
                            width: 2,
                          ),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    _updateProfile();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildEditDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F41BB),
            const Color(0xFF1F41BB).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _editUsernameController.text.isNotEmpty 
              ? _editUsernameController.text[0].toUpperCase() 
              : _username.isNotEmpty 
                  ? _username[0].toUpperCase() 
                  : 'U',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Future<void> _pickProfileImage(StateSetter setState) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Foto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F41BB),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _getImageFromSource(ImageSource.camera, setState);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _getImageFromSource(ImageSource.gallery, setState);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1F41BB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1F41BB).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF1F41BB),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F41BB),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _getImageFromSource(ImageSource source, StateSetter setState) async {
    try {
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission kamera diperlukan untuk mengambil foto'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedProfileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateProfile() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memperbarui profile...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Update profile data
      final result = await _authService.updateProfile(
        username: _editUsernameController.text.trim(),
        phone: _editPhoneController.text.trim(),
        profileImagePath: _selectedProfileImage?.path,
      );
      
      if (result['success']) {
        // Reload user data
        await _loadUserData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Profile berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memperbarui profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        automaticallyImplyLeading: false,
        title: Text(
          'Profile Anda',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F41BB),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF1F41BB),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  
                  // Avatar
                  _buildAvatar(),
                  const SizedBox(height: 24),
                  
                  // User Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Pengguna',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F41BB),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Username
                          _buildInfoRow(
                            icon: Icons.person_outline,
                            label: 'Username',
                            value: _username,
                          ),
                          const SizedBox(height: 16),
                          
                          // Email
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _email,
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Nomor Telepon',
                            value: _phone.isNotEmpty ? _phone : 'Belum diisi',
                          ),
                          const SizedBox(height: 16),
                          
                          // Role
                          _buildInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Role',
                            value: _role == 'satpam' ? 'Satpam' : 'User',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showLogoutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1F41BB),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: _urlFotoIdentitas.isNotEmpty
              ? Image.network(
                  _urlFotoIdentitas,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1F41BB),
                        ),
                      ),
                    );
                  },
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }
  
  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F41BB),
            const Color(0xFF1F41BB).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF1F41BB),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
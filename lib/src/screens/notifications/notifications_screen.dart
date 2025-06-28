import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../reports/user_reports_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();
      _currentUserId = userData['id'] ?? '';
      final notifications = await _notificationService.getNotificationsByUserId(_currentUserId);
      setState(() {
        _notifications = notifications;
      });
        } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    await _loadNotifications(); // Refresh list
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId.isNotEmpty) {
      await _notificationService.markAllAsReadForUser(_currentUserId);
      await _loadNotifications(); // Refresh list
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final success = await _notificationService.deleteNotification(notificationId);
    if (success) {
      await _loadNotifications(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToReportDetail(String reportId) {
    // Navigate to user reports screen and highlight the specific report
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserReportsScreen(),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade200 : const Color(0xFF1F41BB).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          _navigateToReportDetail(notification.reportId);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                        color: const Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F41BB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'mark_read' && !notification.isRead) {
                        _markAsRead(notification.id);
                      } else if (value == 'delete') {
                        _deleteNotification(notification.id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read, size: 18, color: Color(0xFF1F41BB)),
                              SizedBox(width: 8),
                              Text('Tandai Dibaca'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(notification.newStatus),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      notification.newStatus,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cocok':
      case 'matched':
        return const Color(0xFF4CAF50);
      case 'proses':
        return const Color(0xFFFF9800);
      case 'selesai':
        return const Color(0xFF1F41BB);
      case 'terverifikasi':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul ketika ada\nperubahan status pada laporan Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F41BB),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F41BB)),
        actions: [
          if (_notifications.isNotEmpty && unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tandai Semua Dibaca',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1F41BB),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
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
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFF1F41BB),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_notifications[index]);
                    },
                  ),
                ),
    );
  }
}
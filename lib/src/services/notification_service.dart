import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'dart:math';

class NotificationService {
  static const String _notificationsKey = 'notifications';
  static const String _unreadCountKey = 'unread_notifications_count';

  // Simpan notifikasi baru
  Future<bool> addNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      
      notifications.insert(0, notification); // Insert at beginning for newest first
      
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
      
      // Update unread count
      await _updateUnreadCount();
      
      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  // Ambil semua notifikasi untuk user tertentu
  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    try {
      final allNotifications = await getAllNotifications();
      return allNotifications.where((n) => n.userId == userId).toList();
    } catch (e) {
      print('Error getting notifications by user ID: $e');
      return [];
    }
  }

  // Ambil semua notifikasi
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_notificationsKey);
      
      if (notificationsString == null) {
        return [];
      }
      
      final List<dynamic> notificationsJson = jsonDecode(notificationsString);
      return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all notifications: $e');
      return [];
    }
  }

  // Tandai notifikasi sebagai sudah dibaca
  Future<bool> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        
        final notificationsJson = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
        
        // Update unread count
        await _updateUnreadCount();
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Tandai semua notifikasi user sebagai sudah dibaca
  Future<bool> markAllAsReadForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      
      bool hasChanges = false;
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].userId == userId && !notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        final notificationsJson = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
        
        // Update unread count
        await _updateUnreadCount();
      }
      
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Ambil jumlah notifikasi yang belum dibaca untuk user tertentu
  Future<int> getUnreadCountForUser(String userId) async {
    try {
      final notifications = await getNotificationsByUserId(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Update unread count di SharedPreferences
  Future<void> _updateUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      await prefs.setInt(_unreadCountKey, unreadCount);
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  // Buat notifikasi untuk perubahan status laporan
  Future<bool> createStatusChangeNotification({
    required String userId,
    required String reportId,
    required String reportName,
    required String oldStatus,
    required String newStatus,
  }) async {
    try {
      final notificationId = 'NOTIF_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      String title = '';
      String message = '';
      
      if (newStatus.toLowerCase() == 'cocok' || newStatus.toLowerCase() == 'matched') {
        title = 'Laporan Berhasil Dicocokkan!';
        message = 'Laporan "$reportName" Anda telah berhasil dicocokkan oleh petugas keamanan. Status berubah dari "$oldStatus" menjadi "$newStatus".';
      } else if (newStatus.toLowerCase() == 'terverifikasi') {
        title = 'Laporan Terverifikasi';
        message = 'Laporan "$reportName" Anda telah diverifikasi oleh petugas keamanan.';
      } else if (newStatus.toLowerCase() == 'selesai') {
        title = 'Laporan Selesai';
        message = 'Laporan "$reportName" Anda telah diselesaikan.';
      } else {
        title = 'Status Laporan Diperbarui';
        message = 'Status laporan "$reportName" Anda telah diperbarui dari "$oldStatus" menjadi "$newStatus".';
      }
      
      final notification = NotificationModel(
        id: notificationId,
        title: title,
        message: message,
        reportId: reportId,
        reportName: reportName,
        oldStatus: oldStatus,
        newStatus: newStatus,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
      );
      
      return await addNotification(notification);
    } catch (e) {
      print('Error creating status change notification: $e');
      return false;
    }
  }

  // Hapus notifikasi
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      
      notifications.removeWhere((n) => n.id == notificationId);
      
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
      
      // Update unread count
      await _updateUnreadCount();
      
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Hapus semua notifikasi untuk user tertentu
  Future<bool> deleteAllNotificationsForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();
      
      notifications.removeWhere((n) => n.userId == userId);
      
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
      
      // Update unread count
      await _updateUnreadCount();
      
      return true;
    } catch (e) {
      print('Error deleting all notifications for user: $e');
      return false;
    }
  }
}
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import 'database_service.dart';
import 'notification_service.dart';

/// Provider for managing app notifications
class NotificationProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Load all notifications from database
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _dbService.getAllNotifications();
      _unreadCount = await _dbService.getUnreadNotificationCount();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new notification and show it as a push notification
  Future<void> addNotification(AppNotification notification, {bool showPush = true}) async {
    try {
      final id = await _dbService.insertNotification(notification);
      final newNotification = notification.copyWith(id: id);
      _notifications.insert(0, newNotification);
      _unreadCount++;
      notifyListeners();
      
      // Show push notification
      if (showPush) {
        await _notificationService.showNotification(
          id: id,
          title: notification.title,
          body: notification.body,
          payload: notification.machineId != null 
              ? 'machine_${notification.machineId}' 
              : 'test_notification',
          machineId: notification.machineId,
        );
      }
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dbService.markNotificationAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Delete a specific notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _dbService.deleteNotification(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        if (!_notifications[index].isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
        }
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _dbService.deleteAllNotifications();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  /// Send a test notification
  Future<void> sendTestNotification() async {
    final testNotification = AppNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working correctly.',
      createdAt: DateTime.now(),
    );
    
    await addNotification(testNotification);
  }
}

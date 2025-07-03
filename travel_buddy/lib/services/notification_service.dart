import 'api_service.dart';

class NotificationService {
  // Get user notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await ApiService.get('/notifications');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.put('/notifications/$notificationId/read', {});
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get unread notification count
  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await ApiService.get('/notifications/unread-count');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Register device token for push notifications
  static Future<Map<String, dynamic>> registerDeviceToken(String deviceToken) async {
    try {
      final response = await ApiService.post('/notifications/register', {
        'deviceToken': deviceToken,
      });
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete device token
  static Future<Map<String, dynamic>> deleteDeviceToken(String deviceToken) async {
    try {
      final response = await ApiService.delete('/notifications/tokens/$deviceToken');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }
} 
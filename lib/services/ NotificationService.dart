import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/notification/AppNotification.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

/// Service that talks to the notifications API.
class NotificationService {
  /// GET /notifications_read_view/{userId}
  Future<NotificationsPayload> fetchNotificationList(int userId) async {
    try {
      final res = await ApiService.get('/notifications_read_view/$userId');
      return NotificationsPayload.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /notifications_count/{userId}
  /// Returns the numeric unread count from server
  Future<int> fetchCount(int userId) async {
    try {
      final res = await ApiService.get('/notifications_count/$userId');
      final payload = NotificationsPayload.fromJson(res.data);
      return payload.notificationCount;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /notifications_read
  /// FormData: user_id, notification_id
  Future<void> markRead({
    required int userId,
    required int notificationId,
  }) async {
    final form = FormData.fromMap({
      'user_id': userId.toString(),
      'notification_id': notificationId.toString(),
    });

    final res = await ApiService.post('/notifications_read', form);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'Failed to mark read');
    }
  }
}

import 'package:get/get.dart';
import 'package:urbantutorsapp/models/notification/AppNotification.dart';
import 'package:urbantutorsapp/services/%20NotificationService.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

/// GetX controller that owns Notification state.
class NotificationController extends GetxController {
  final NotificationService _svc = NotificationService();

  // Reactive state
  final isLoading = false.obs;
  final markingAll = false.obs;
  final error = ''.obs;

  final userId = 0.obs;
  final items = <AppNotification>[].obs;
  final unreadCount = 0.obs;

  /// Bootstraps by pulling userId from storage, then loading data.
  Future<void> bootstrap() async {
    isLoading.value = true;
    error.value = '';
    try {
      final uidStr = await StorageService.getUserId();
      final uid = int.tryParse(uidStr ?? '') ?? 0;
      if (uid <= 0) throw Exception('No user id found');

      userId.value = uid;

      final payload = await _svc.fetchNotificationList(uid);
      final count = await _svc.fetchCount(uid);

      items.assignAll(payload.items);
      unreadCount.value = count;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    try {
      final uid = userId.value;
      if (uid <= 0) return;
      final payload = await _svc.fetchNotificationList(uid);
      final count = await _svc.fetchCount(uid);
      items.assignAll(payload.items);
      unreadCount.value = count;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> markOne(AppNotification n) async {
    if (n.isRead == 1) return;
    try {
      await _svc.markRead(userId: userId.value, notificationId: n.id);
      // Optimistically update list and unread count
      final idx = items.indexWhere((x) => x.id == n.id);
      if (idx != -1) {
        final x = items[idx];
        items[idx] = AppNotification(
          id: x.id,
          message: x.message,
          image: x.image,
          status: x.status,
          isRead: 1,
          messageCreatedAt: x.messageCreatedAt,
          messageSentTime: x.messageSentTime,
          readAt: x.readAt,
        );
        if (unreadCount.value > 0) {
          unreadCount.value = unreadCount.value - 1;
        }
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> markAll() async {
    if (markingAll.value) return;
    markingAll.value = true;
    try {
      final unread = items.where((e) => e.isRead == 0).toList();
      for (final n in unread) {
        await _svc.markRead(userId: userId.value, notificationId: n.id);
      }
      await refreshAll();
    } catch (e) {
      error.value = e.toString();
    } finally {
      markingAll.value = false;
    }
  }
}

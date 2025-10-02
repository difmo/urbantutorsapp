class AppNotification {
  final int id;
  final String message;
  final String? image; // filename or url
  final int status;
  final int isRead; // 0/1
  final String? messageCreatedAt; // ISO
  final String? messageSentTime; // "YYYY-MM-DD HH:mm:ss"
  final String? readAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.image,
    required this.status,
    required this.isRead,
    required this.messageCreatedAt,
    required this.messageSentTime,
    required this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: _toInt(j['id']),
        message: (j['message'] ?? '').toString(),
        image: j['image']?.toString(),
        status: _toInt(j['status']),
        isRead: _toInt(j['is_read']),
        messageCreatedAt: j['message_created_at']?.toString(),
        messageSentTime: j['message_sent_time']?.toString(),
        readAt: j['read_at']?.toString(),
      );
      
}


class NotificationsPayload {
  final int userId;
  final String userName;
  final String userMobile;
  final int notificationCount;
  final List<AppNotification> items;

  NotificationsPayload({
    required this.userId,
    required this.userName,
    required this.userMobile,
    required this.notificationCount,
    required this.items,
  });

  factory NotificationsPayload.fromJson(Map<String, dynamic> j) {
    final list = (j['notifications'] as List? ?? [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationsPayload(
      userId: _toInt(j['user_id']),
      userName: (j['user_name'] ?? '').toString(),
      userMobile: (j['user_mobile'] ?? '').toString(),
      notificationCount: _toInt(j['notification_count']),
      items: list,
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

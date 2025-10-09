  class MyCoursePayload {
  final bool success;
  final List<MyCourseItem> items;
  final String message;

  MyCoursePayload({
    required this.success,
    required this.items,
    required this.message,
  });

  factory MyCoursePayload.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? []);
    final items = <MyCourseItem>[];
    for (final e in list) {
      final map = e as Map<String, dynamic>;
      final pc = map['paycourse'] as Map<String, dynamic>?;
      if (pc != null) {
        items.add(MyCourseItem.fromJson(pc));
      }
    }
    return MyCoursePayload(
      success: json['success'] == true,
      items: items,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class MyCourseItem {
  final int courseId;
  final int userId;
  final String image;       // may be a filename
  final String courseName;
  final int number;         // e.g., sequence/index (backend field)
  final double rating;
  final int coins;
  final String description;
  final int status;
  final String createdAt;   // keep raw for display if needed
  final String updatedAt;

  MyCourseItem({
    required this.courseId,
    required this.userId,
    required this.image,
    required this.courseName,
    required this.number,
    required this.rating,
    required this.coins,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyCourseItem.fromJson(Map<String, dynamic> json) {
    num(dynamic v) => v ? v : (num(v).tryParse('$v') ?? 0);
    double dbl(dynamic v) => num(v).toDouble();
     int(dynamic v) => num(v).toInt();

    return MyCourseItem(
      courseId: int(json['course_id']),
      userId: int(json['user_id']),
      image: (json['image'] ?? '').toString(),
      courseName: (json['course_name'] ?? '').toString(),
      number: int(json['number']),
      rating: dbl(json['rating']),
      coins: int(json['coins']),
      description: (json['description'] ?? '').toString(),
      status: int(json['status']),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }
}

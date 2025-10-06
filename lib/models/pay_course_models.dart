class PayCoursesPayload {
  final bool success;
  final List<PayCourse> items;
  final String message;

  PayCoursesPayload({
    required this.success,
    required this.items,
    required this.message,
  });

  factory PayCoursesPayload.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List? ?? [])
        .map((e) => PayCourse.fromJson(e as Map<String, dynamic>))
        .toList();
    return PayCoursesPayload(
      success: json['success'] == true,
      items: data,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class PayCourse {
  final int id;
  final String courseName;
  final String description;
  final int coins;
  final double rating;
  final String? pdf;        // optional (sometimes present)
  final String? thumbnail;  // optional

  PayCourse({
    required this.id,
    required this.courseName,
    required this.description,
    required this.coins,
    required this.rating,
    this.pdf,
    this.thumbnail,
  });

  factory PayCourse.fromJson(Map<String, dynamic> json) {
    num _num(dynamic v) => (v is num) ? v : (num.tryParse('$v') ?? 0);
    double _dbl(dynamic v) => _num(v).toDouble();
    int _int(dynamic v) => _num(v).toInt();

    return PayCourse(
      id: _int(json['id']),
      courseName: (json['course_name'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      coins: _int(json['coins']),
      rating: _dbl(json['rating']),
      pdf: (json['pdf'] ?? '').toString().isEmpty ? null : json['pdf'].toString(),
      thumbnail: (json['thumbnail'] ?? '').toString().isEmpty ? null : json['thumbnail'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_name': courseName,
    'description': description,
    'coins': coins,
    'rating': rating,
    'pdf': pdf,
    'thumbnail': thumbnail,
  };
}

class PurchaseResponse {
  final bool success;
  final String message;

  PurchaseResponse({required this.success, required this.message});

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class ViewCourseResponse {
  /// e.g. "pdf" / "video" / etc (backend-specific)
  final String type;
  /// absolute or relative file/url for opening
  final String url;
  final bool success;
  final String message;

  ViewCourseResponse({
    required this.type,
    required this.url,
    required this.success,
    required this.message,
  });

  factory ViewCourseResponse.fromJson(Map<String, dynamic> json) {
    // Be flexible about backend shape
    final data = json['data'];
    String? foundUrl;
    String? foundType;

    if (data is Map<String, dynamic>) {
      foundUrl = (data['url'] ?? data['file'] ?? data['pdf'] ?? '').toString();
      foundType = (data['type'] ?? data['Type'] ?? '').toString();
      if (foundType == 'null') foundType = '';
    } else if (data is String) {
      foundUrl = data;
      foundType = '';
    }

    return ViewCourseResponse(
      type: (foundType ?? '').isEmpty ? (json['type'] ?? '').toString() : foundType!,
      url: (foundUrl ?? '').toString(),
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

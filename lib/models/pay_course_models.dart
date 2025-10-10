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
    final raw = json['data'];
    final items = <PayCourse>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          items.add(PayCourse.fromJson(e));
        } else if (e is Map) {
          // in case it's Map<dynamic, dynamic>
          items.add(PayCourse.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return PayCoursesPayload(
      success: json['success'] == true,
      items: items,
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
  final String? pdf; // optional
  final String? thumbnail; // optional
  final int? status;
  final int? number;

  PayCourse({
    required this.id,
    required this.courseName,
    required this.description,
    required this.coins,
    required this.rating,
    this.pdf,
    this.thumbnail,
    this.status,
    this.number,
  });

  factory PayCourse.fromJson(Map<String, dynamic> json) {
    // helper parsers
    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      final s = v.toString();
      return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
    }

    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s) ?? 0.0;
    }

    String? _parseNullableString(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    // pick course name from possible keys
    String _courseNameFromJson(Map<String, dynamic> j) {
      final n = (j['course_name'] ?? j['name'] ?? '').toString().trim();
      return n.isEmpty ? 'Unknown Course' : n;
    }

    return PayCourse(
      id: _parseInt(json['id']),
      courseName: _courseNameFromJson(json),
      description: (json['description'] ?? '').toString(),
      coins: _parseInt(json['coins']),
      rating: _parseDouble(json['rating']),
      pdf: _parseNullableString(json['pdf']),
      thumbnail: _parseNullableString(json['thumbnail'] ?? json['image']),
      status: json.containsKey('status') ? _parseInt(json['status']) : null,
      number: json.containsKey('number') ? _parseInt(json['number']) : null,
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
        'status': status,
        'number': number,
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

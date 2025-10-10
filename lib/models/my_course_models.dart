// models/my_course.dart

import 'package:dio/dio.dart';

/// Small helpers for robust parsing
int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
}

double _parseDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  final s = v.toString().trim();
  return double.tryParse(s) ?? 0.0;
}

String? _parseNullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

/// Top level payload returned by `/mycourse`
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
    final rawList = json['data'];
    final items = <MyCourseItem>[];

    if (rawList is List) {
      for (final e in rawList) {
        if (e == null) continue;
        // Many APIs wrap actual course inside a 'paycourse' object
        if (e is Map) {
          // try 'paycourse' key first
          final dynamic pc = (e as Map).containsKey('paycourse') ? e['paycourse'] : e;
          if (pc is Map<String, dynamic>) {
            items.add(MyCourseItem.fromJson(pc));
          } else if (pc is Map) {
            items.add(MyCourseItem.fromJson(Map<String, dynamic>.from(pc)));
          } else {
            // fallback: try to convert e itself
            try {
              items.add(MyCourseItem.fromJson(Map<String, dynamic>.from(e)));
            } catch (_) {
              // ignore malformed entry
            }
          }
        }
      }
    }

    return MyCoursePayload(
      success: json['success'] == true,
      items: items,
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': items.map((i) => i.toJson()).toList(),
        'message': message,
      };
}

/// Represents a single purchased course entry (the 'paycourse' object)
class MyCourseItem {
  final int courseId;
  final int userId;
  final String? image; // may be filename
  final String courseName;
  final int number;
  final double rating;
  final int coins;
  final String description;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    // normalize keys: sometimes API returns snake_case or camelCase
    final map = Map<String, dynamic>.from(json);

    return MyCourseItem(
      courseId: _parseInt(map['course_id'] ?? map['courseId'] ?? map['id']),
      userId: _parseInt(map['user_id'] ?? map['userId']),
      image: _parseNullableString(map['image']),
      courseName: (_parseNullableString(map['course_name'] ?? map['courseName']) ?? 'Unknown Course'),
      number: _parseInt(map['number']),
      rating: _parseDouble(map['rating']),
      coins: _parseInt(map['coins']),
      description: (map['description'] ?? '').toString(),
      status: _parseInt(map['status']),
      createdAt: _parseDateTime(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDateTime(map['updated_at'] ?? map['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'user_id': userId,
        'image': image,
        'course_name': courseName,
        'number': number,
        'rating': rating,
        'coins': coins,
        'description': description,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// helper to get full remote URL for image when only filename is provided.
  String getImageUrl({required String baseUrl}) {
    if (image == null) return '';
    final i = image!;
    if (i.startsWith('http')) return i;
    return '$baseUrl/public/admin/uploads/paycourse/${Uri.encodeComponent(i)}';
  }
}

/// Model for view pdf response: { data: { url: '...', type: 'pdf' } }
class ViewInfo {
  final String url;
  final String type;

  ViewInfo({
    required this.url,
    required this.type,
  });

  factory ViewInfo.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    if (d is Map) {
      final url = (d['url'] ?? d['file'] ?? d['pdf'] ?? d['path'] ?? '').toString();
      final type = (d['type'] ?? d['Type'] ?? '').toString();
      return ViewInfo(url: url, type: type);
    }
    return ViewInfo(url: '', type: '');
  }

  Map<String, dynamic> toJson() => {'data': {'url': url, 'type': type}};
}

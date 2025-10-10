// models/master_data.dart

import 'dart:core';

/// --- Helpers ---
int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
}

double _double(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  final s = v.toString().trim();
  return double.tryParse(s) ?? 0.0;
}

String? _nullableString(dynamic v) {
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

/// --- Top-level response ---
class MasterDataResponse {
  final bool success;
  final MasterData data;
  final String message;

  MasterDataResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory MasterDataResponse.fromJson(Map<String, dynamic> json) {
    return MasterDataResponse(
      success: json['success'] == true,
      data: MasterData.fromJson(json['data'] ?? <String, dynamic>{}),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.toJson(),
        'message': message,
      };
}

/// --- MasterData ---
class MasterData {
  final String? privacyPolicy;
  final List<BoardLead> boardLead;
  final List<BoardLead> boardNotePyq;
  final List<Teacher> teachers;
  final List<Student> students;
  final List<TutorBeuro> tutorBeuroList;
  final List<SubscriptionPlan> teacherProSubscription;
  final List<Role> roles;

  MasterData({
    required this.privacyPolicy,
    required this.boardLead,
    required this.boardNotePyq,
    required this.teachers,
    required this.students,
    required this.tutorBeuroList,
    required this.teacherProSubscription,
    required this.roles,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    T _safeParseList<T>(
        dynamic src, T Function(Map<String, dynamic>) converter) {
      final out = <T>[];
      if (src is List) {
        for (final e in src) {
          if (e is Map<String, dynamic>) {
            out.add(converter(e));
          } else if (e is Map) {
            out.add(converter(Map<String, dynamic>.from(e)));
          }
        }
      }
      return out as T;
    }

    final privacy = _nullableString(json['privacy_Policy'] ?? json['privacyPolicy']);

    final boardLead = <BoardLead>[];
    if (json['board_Lead'] is List) {
      for (final e in json['board_Lead']) {
        if (e is Map) boardLead.add(BoardLead.fromJson(Map.from(e)));
      }
    }

    final boardNotePyq = <BoardLead>[];
    if (json['board_NotePyq'] is List) {
      for (final e in json['board_NotePyq']) {
        if (e is Map) boardNotePyq.add(BoardLead.fromJson(Map.from(e)));
      }
    }

    final teachers = <Teacher>[];
    if (json['teachers_list'] is List) {
      for (final e in json['teachers_list']) {
        if (e is Map) teachers.add(Teacher.fromJson(Map.from(e)));
      }
    }

    final students = <Student>[];
    if (json['student_list'] is List) {
      for (final e in json['student_list']) {
        if (e is Map) students.add(Student.fromJson(Map.from(e)));
      }
    }

    final tutorBeuro = <TutorBeuro>[];
    if (json['tutor_beuro_list'] is List) {
      for (final e in json['tutor_beuro_list']) {
        if (e is Map) tutorBeuro.add(TutorBeuro.fromJson(Map.from(e)));
      }
    }

    final teacherSubscriptions = <SubscriptionPlan>[];
    if (json['teacher_pro_subscription'] is List) {
      for (final e in json['teacher_pro_subscription']) {
        if (e is Map) teacherSubscriptions.add(SubscriptionPlan.fromJson(Map.from(e)));
      }
    }

    final roles = <Role>[];
    if (json['roles'] is List) {
      for (final e in json['roles']) {
        if (e is Map) roles.add(Role.fromJson(Map.from(e)));
      }
    }

    return MasterData(
      privacyPolicy: privacy,
      boardLead: boardLead,
      boardNotePyq: boardNotePyq,
      teachers: teachers,
      students: students,
      tutorBeuroList: tutorBeuro,
      teacherProSubscription: teacherSubscriptions,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() => {
        'privacy_Policy': privacyPolicy,
        'board_Lead': boardLead.map((b) => b.toJson()).toList(),
        'board_NotePyq': boardNotePyq.map((b) => b.toJson()).toList(),
        'teachers_list': teachers.map((t) => t.toJson()).toList(),
        'student_list': students.map((s) => s.toJson()).toList(),
        'tutor_beuro_list': tutorBeuroList.map((t) => t.toJson()).toList(),
        'teacher_pro_subscription': teacherProSubscription.map((s) => s.toJson()).toList(),
        'roles': roles.map((r) => r.toJson()).toList(),
      };
}

/// --- BoardLead ---
class BoardLead {
  final int boardId;
  final String boardLabel;

  BoardLead({required this.boardId, required this.boardLabel});

  factory BoardLead.fromJson(Map<String, dynamic> json) {
    return BoardLead(
      boardId: _int(json['board_Id'] ?? json['boardId'] ?? json['id']),
      boardLabel: (json['board_lable'] ?? json['board_label'] ?? json['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'board_Id': boardId,
        'board_lable': boardLabel,
      };
}

/// --- Teacher ---
class Teacher {
  final int teacherId;
  final String teacherUserId;
  final String name;
  final String mobile;

  Teacher({
    required this.teacherId,
    required this.teacherUserId,
    required this.name,
    required this.mobile,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: _int(json['teacher_id'] ?? json['id']),
      teacherUserId: _nullableString(json['teacher_user_id']) ?? _nullableString(json['teacher_userId']) ?? '',
      name: _nullableString(json['name']) ?? '',
      mobile: _nullableString(json['mobile']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'teacher_id': teacherId,
        'teacher_user_id': teacherUserId,
        'name': name,
        'mobile': mobile,
      };
}

/// --- Student ---
class Student {
  final int studentId;
  final String studentUserId;
  final String name;
  final String mobile;

  Student({
    required this.studentId,
    required this.studentUserId,
    required this.name,
    required this.mobile,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: _int(json['student_id'] ?? json['id']),
      studentUserId: _nullableString(json['student_user_id']) ?? _nullableString(json['student_userId']) ?? '',
      name: _nullableString(json['name']) ?? '',
      mobile: _nullableString(json['mobile']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'student_user_id': studentUserId,
        'name': name,
        'mobile': mobile,
      };
}

/// --- TutorBeuro ---
class TutorBeuro {
  final int tutorBeuroId;
  final String name;
  final String mobile;

  TutorBeuro({
    required this.tutorBeuroId,
    required this.name,
    required this.mobile,
  });

  factory TutorBeuro.fromJson(Map<String, dynamic> json) {
    return TutorBeuro(
      tutorBeuroId: _int(json['tutor_beuro_id'] ?? json['id']),
      name: _nullableString(json['name']) ?? '',
      mobile: _nullableString(json['mobile']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'tutor_beuro_id': tutorBeuroId,
        'name': name,
        'mobile': mobile,
      };
}

/// --- SubscriptionPlan (used for teacher_pro_subscription) ---
class SubscriptionPlan {
  final int id;
  final String subscriptionType; // e.g. "Top View"
  final int duration;
  final String price;
  final String description;
  final int status;
  final DateTime? createdAt;

  SubscriptionPlan({
    required this.id,
    required this.subscriptionType,
    required this.duration,
    required this.price,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: _int(json['id']),
      subscriptionType: _nullableString(json['subscription_type']) ?? '',
      duration: _int(json['duration']),
      price: _nullableString(json['price']) ?? '',
      description: _nullableString(json['description']) ?? '',
      status: _int(json['status']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscription_type': subscriptionType,
        'duration': duration,
        'price': price,
        'description': description,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}

/// --- Role ---
class Role {
  final int id;
  final String name;
  final String slug;

  Role({required this.id, required this.name, required this.slug});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: _int(json['id']),
      name: _nullableString(json['name']) ?? '',
      slug: _nullableString(json['slug']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };
}

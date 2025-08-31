import 'dart:convert';
import 'package:http/http.dart' as http;

class LeadClass {
  final int courseId;
  final String courseName;
  LeadClass({required this.courseId, required this.courseName});


  factory LeadClass.fromJson(Map<String, dynamic> j) {
    final rawId = j['course_id'] ?? j['id'] ?? j['class_id'] ?? j['courseId'];
    final rawName = j['course_name'] ??
        j['name'] ??
        j['class_name'] ??
        j['coursename'] ??
        j['label'] ??
        j['title'];
    return LeadClass(
        courseId: int.tryParse('$rawId') ?? 0, courseName: (rawName ?? '').toString());
  }
}

class LeadSubject {
  final int subjectId;
  final String subjectName;
  LeadSubject({required this.subjectId, required this.subjectName});

  factory LeadSubject.fromJson(Map<String, dynamic> j) {
    final rawId = j['subject_id'] ?? j['id'];
    final rawName = j['subjectname'] ?? j['subject_name'] ?? j['name'];
    return LeadSubject(
        subjectId: int.tryParse('$rawId') ?? 0, subjectName: (rawName ?? '').toString());
  }
}

class LeadMetaService {
  static const _base = 'https://urbantutors.pro/api';
  Future<List<LeadClass>> getClassesByBoard(int boardId) async {
    final uri = Uri.parse('$_base/leadclassget');
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'board_id': boardId.toString()},
    );
    print("[API] POST ${res.body}");
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final list = body['data'] ?? [];
      return List.from(list)
          .map((e) => LeadClass.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load classes (${res.statusCode})');
  }

  Future<List<LeadSubject>> getSubjectsByClassAndBoard(
      {required int classId, required int boardId}) async {
    final uri = Uri.parse('$_base/leadgetsubjects');
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'board_id': boardId.toString(), 'class_id': classId.toString()},
    );
    print("[API] POST ${res.body}");
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final list = body['data'] ?? [];
      return List.from(list)
          .map((e) => LeadSubject.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load subjects (${res.statusCode})');
  }
}

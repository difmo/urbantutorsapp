import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbantutorsapp/models/notes_models.dart.dart';

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

class LeadChapter {
  final int chapterId;
  final String chapterName;
  LeadChapter({required this.chapterId, required this.chapterName});

  factory LeadChapter.fromJson(Map<String, dynamic> j) {
    final rawId = j['chapter_id'] ?? j['ChapterName'];
    final rawName = j['ChapterName'] ?? j['ChapterName'];
    return LeadChapter(
        chapterId: int.tryParse('$rawId') ?? 0, chapterName: (rawName ?? '').toString());
  }
}
class ChapterDetailsResponse {
  final bool success;
  final ChapterDetailsData data;
  final String message;

  ChapterDetailsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ChapterDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsResponse(
      success: json['success'] ?? false,
      data: ChapterDetailsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ChapterDetailsData {
  final String boardName;
  final String className;
  final String subjectName;
  final String chapterName;
  final String imageurl;
  final List<ChapterDetail> chapterDetail;

  ChapterDetailsData({
    required this.boardName,
    required this.className,
    required this.subjectName,
    required this.chapterName,
    required this.imageurl,
    required this.chapterDetail,
  });

  factory ChapterDetailsData.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsData(
      boardName: json['boardName'] ?? '',
      className: json['className'] ?? '',
      subjectName: json['subjectName'] ?? '',
      chapterName: json['chapterName'] ?? '',
      imageurl: json['imageurl'] ?? '',
      chapterDetail: (json['chapter_detail'] as List<dynamic>? ?? [])
          .map((e) => ChapterDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterDetail {
  final int id;
  final int boardId;
  final int boardclassId;
  final int boardsubjectId;
  final int chapterId;
  final String type;
  final String hedingName;
  final String image;
  final String content;
  final int status;
  final String createdAt;
  final String updatedAt;

  ChapterDetail({
    required this.id,
    required this.boardId,
    required this.boardclassId,
    required this.boardsubjectId,
    required this.chapterId,
    required this.type,
    required this.hedingName,
    required this.image,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    return ChapterDetail(
      id: json['id'] ?? 0,
      boardId: json['board_id'] ?? 0,
      boardclassId: json['boardclass_id'] ?? 0,
      boardsubjectId: json['boardsubject_id'] ?? 0,
      chapterId: json['chapter_id'] ?? 0,
      type: json['type'] ?? '',
      hedingName: json['heding_name'] ?? '',
      image: json['image'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
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

  Future<List<LeadChapter>> getChaptersBySubject({
    required int subjectId,
    required String type
  }) async {
    final uri = Uri.parse('$_base/leadgetchapters');
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'subject_id': subjectId.toString(),
        'type': type,
      },
    );
    print("[API] POST ${res.body}");
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final list = body['data'] ?? [];
      return List.from(list)
          .map((e) => LeadChapter.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load chapters (${res.statusCode})');
  }

  Future<ChapterDetails> getChapterDetails({
    required int chapterId,
    required String type,
  }) async {
    final uri = Uri.parse('$_base/getchapterdetails');
    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'chapter_id': chapterId.toString(),
        'type': type,
      },
    );
    print("[API] POST ${res.body}");
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final data = body['data'] ?? {};
      return ChapterDetails.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Failed to load chapter details (${res.statusCode})');
  } 

}

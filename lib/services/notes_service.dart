import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';

class NotesService {
  static const _classesUrl  = 'https://urbantutors.pro/api/getclassesboard';
  static const _subjectsUrl = 'https://urbantutors.pro/api/getsubjects';
  static const _chaptersUrl = 'https://urbantutors.pro/api/getchapter';
  static const _detailUrl   = 'https://urbantutors.pro/api/getchapter_details';

  final String? token; // optional bearer
  NotesService({this.token});

  Map<String, String> _headers({bool form = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
      if (form) 'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (token != null && token!.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  // Tiny debug
  void _dbg(String msg) { if (kDebugMode) debugPrint('[NOTES] $msg'); }

  Future<List<NotesClass>> fetchClasses({required int boardId, String type = 'Note'}) async {
    _dbg('POST $_classesUrl body={board_id:$boardId,type:$type}');
    final res = await http.post(Uri.parse(_classesUrl), headers: _headers(), body: {
      'board_id': '$boardId',
      'type': type,
    });
    _dbg('classes status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getclassesboard failed: ${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List<dynamic>? ?? []);
    return list.map((e) => NotesClass.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<NotesSubject>> fetchSubjects({required int classId, String type = 'Note'}) async {
    _dbg('POST $_subjectsUrl body={class_id:$classId,type:$type}');
    final res = await http.post(Uri.parse(_subjectsUrl), headers: _headers(), body: {
      'class_id': '$classId',
      'type': type,
    });
    _dbg('subjects status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getsubjects failed: ${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List<dynamic>? ?? []);
    return list.map((e) => NotesSubject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<NotesChapter>> fetchChapters({required int subjectId, String type = 'Note'}) async {
    _dbg('POST $_chaptersUrl body={subject_id:$subjectId,type:$type}');
    final res = await http.post(Uri.parse(_chaptersUrl), headers: _headers(), body: {
      'subject_id': '$subjectId',
      'type': type,
    });
    _dbg('chapters status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getchapter failed: ${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List<dynamic>? ?? []);
    return list.map((e) => NotesChapter.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChapterDetails> fetchChapterDetails({required int chapterId, String type = 'Note'}) async {
    _dbg('POST $_detailUrl body={chapter_id:$chapterId,type:$type}');
    final res = await http.post(Uri.parse(_detailUrl), headers: _headers(), body: {
      'chapter_id': '$chapterId',
      'type': type,
    });
    _dbg('details status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getchapter_details failed: ${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ChapterDetails.fromJson(map);
  }

  // Build full image URL safely
  static String buildImageUrl(String base, String file) {
    if (base.isEmpty || file.isEmpty) return '';
    final uri = Uri.parse(base.endsWith('/') ? base + Uri.encodeComponent(file)
                                             : '$base/${Uri.encodeComponent(file)}');
    return uri.toString();
  }
}

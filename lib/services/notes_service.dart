import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';
import 'package:urbantutorsapp/services/api_exception.dart';

// Define BASE_URL for image URL construction
const String BASE_URL = 'https://urbantutors.pro';

class NotesService {
  static const _classesUrl = 'https://urbantutors.pro/api/getclasses';
  static const _subjectsUrl = 'https://urbantutors.pro/api/getsubjects';
  static const _chaptersUrl = 'https://urbantutors.pro/api/getchapter';
  static const _detailUrl = 'https://urbantutors.pro/api/getchapter_details';

  final String? token; // optional bearer
  NotesService({this.token});

  Map<String, String> _headers({bool form = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
      if (form) 'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<http.Response> _post(String url, Map<String, String> body) async {
    try {
      return await http
          .post(Uri.parse(url), headers: _headers(), body: body)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException(
          'The server is taking too long to respond. Please try again.');
    } on SocketException {
      throw const ApiException(
          'No internet connection. Please check your network and try again.');
    }
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) return body;
    } on FormatException {
      // fall through
    }
    throw const ApiException(
        'Unexpected response from server. Please try again later.');
  }

  // Tiny debug
  void _dbg(String msg) {
    if (kDebugMode) debugPrint('[NOTES] $msg');
  }

  Future<List<NotesClass>> fetchClasses(
      {required int boardId, String type = 'Note'}) async {
    _dbg('POST $_classesUrl body={board_id:$boardId,type:$type}');
    final res = await _post(_classesUrl, {
      'board_id': '$boardId',
      'type': type,
    });
    _dbg('classes status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Could not load content (${res.statusCode}). Please try again.');
    }
    final map = _decode(res);
    final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
    return list
        .map((e) => NotesClass.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotesSubject>> fetchSubjects(
      {required int classId, String type = 'Note'}) async {
    _dbg('POST $_subjectsUrl body={class_id:$classId,type:$type}');
    final res = await _post(_subjectsUrl, {
      'class_id': '$classId',
      'type': type,
    });
    _dbg('subjects status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Could not load content (${res.statusCode}). Please try again.');
    }
    final map = _decode(res);
    final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
    return list
        .map((e) => NotesSubject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotesChapter>> fetchChapters(
      {required int subjectId, String type = 'Note'}) async {
    _dbg('POST $_chaptersUrl body={subject_id:$subjectId,type:$type}');
    final res = await _post(_chaptersUrl, {
      'subject_id': '$subjectId',
      'type': type,
    });
    _dbg('chapters status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Could not load content (${res.statusCode}). Please try again.');
    }
    final map = _decode(res);
    final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
    return list
        .map((e) => NotesChapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChapterDetails> fetchChapterDetails(
      {required int chapterId, String type = 'Note'}) async {
    _dbg('POST $_detailUrl body={chapter_id:$chapterId,type:$type}');
    final res = await _post(_detailUrl, {
      'chapter_id': '$chapterId',
      'type': type,
    });
    _dbg('details status=${res.statusCode} body=${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Could not load content (${res.statusCode}). Please try again.');
    }
    final map = _decode(res);
    final data = map['data'];
    if (data is! Map<String, dynamic>) {
      // e.g. {"success":true,"data":[],"message":"Chapter Id Not Found"}
      throw const ApiException(
          'No content has been added for this chapter yet.');
    }
    return ChapterDetails.fromJson(data);
  }

  // Build full image URL safely
  static String buildImageUrl(String path) {
    if (BASE_URL.isEmpty || path.isEmpty) return '';
    final fullPath = 'public/admin/uploads/chapter_details/$path';
    final uri = Uri.parse(BASE_URL.endsWith('/')
        ? BASE_URL + Uri.encodeComponent(fullPath)
        : '$BASE_URL/${Uri.encodeComponent(fullPath)}');
    return uri.toString();
  }
}

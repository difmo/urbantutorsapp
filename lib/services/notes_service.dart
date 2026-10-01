import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/utils/api_config.dart';

// Define BASE_URL for image URL construction
String get BASE_URL => ApiConfig.serverHost;

class NotesService {
  static String get _classesUrl => ApiConfig.fullGetClassesNotesUrl;
  static String get _subjectsUrl => ApiConfig.fullGetSubjectsUrl;
  static String get _chaptersUrl => ApiConfig.fullGetChapterUrl;
  static String get _detailUrl => ApiConfig.fullGetChapterDetailsUrl;

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
    _dbg('fetchClasses boardId=$boardId type=$type');

    // 1. First fetch from master leadclassget (returns complete classes for all boards including NIOS)
    try {
      final res = await _post(ApiConfig.fullLeadClassGetUrl, {
        'board_id': '$boardId',
      });
      _dbg('leadclassget status=${res.statusCode} body=${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res);
        final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
        if (list.isNotEmpty) {
          return list
              .map((e) => NotesClass.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      _dbg('leadclassget error: $e');
    }

    // 2. Fallback to getclasses if leadclassget returned empty
    try {
      final res = await _post(_classesUrl, {
        'board_id': '$boardId',
        'type': type,
      });
      _dbg('getclasses status=${res.statusCode} body=${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res);
        final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
        return list
            .map((e) => NotesClass.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _dbg('getclasses error: $e');
    }

    return [];
  }

  Future<List<NotesSubject>> fetchSubjects({
    required int boardId,
    required int classId,
    String type = 'Note',
  }) async {
    _dbg('fetchSubjects boardId=$boardId classId=$classId type=$type');

    // 1. Try leadgetsubjects (reliable endpoint returning all real subjects for board and class)
    try {
      final res = await _post(ApiConfig.fullLeadGetSubjectsUrl, {
        'board_id': '$boardId',
        'class_id': '$classId',
      });
      _dbg('leadgetsubjects status=${res.statusCode} body=${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res);
        final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
        if (list.isNotEmpty) {
          return list
              .map((e) => NotesSubject.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      _dbg('leadgetsubjects error: $e');
    }

    // 2. Fallback to legacy getsubjects endpoint
    try {
      final res = await _post(_subjectsUrl, {
        'class_id': '$classId',
        'type': type,
      });
      _dbg('getsubjects status=${res.statusCode} body=${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res);
        final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
        return list
            .map((e) => NotesSubject.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _dbg('getsubjects error: $e');
    }

    return [];
  }

  Future<List<NotesChapter>> fetchChapters({
    required int subjectId,
    int? boardId,
    int? classId,
    String type = 'Note',
  }) async {
    _dbg('POST $_chaptersUrl body={subject_id:$subjectId,type:$type}');
    final body = <String, String>{
      'subject_id': '$subjectId',
      'type': type,
      if (boardId != null) 'board_id': '$boardId',
      if (classId != null) 'class_id': '$classId',
    };
    final res = await _post(_chaptersUrl, body);
    _dbg('chapters status=${res.statusCode} body=${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = _decode(res);
      final list = map['data'] is List ? map['data'] as List<dynamic> : const [];
      return list
          .map((e) => NotesChapter.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
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

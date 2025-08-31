import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for debugPrint (safer for long logs)
import 'package:urbantutorsapp/models/pyq_modals.dart/pyq_class_response_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class PyqServices {
  Future<ClassResponse> fetchClass({
    required String boardId,
    required String type,
  }) async {
    try {
      debugPrint("👉 Fetching classes for boardId=$boardId, type=$type");
      final response = await ApiService.post('/getclasses', {
        'board_id': boardId,
        'type': type,
      });
      debugPrint("✅ fetchClass response: ${response.data}");
      return ClassResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e, 'fetchClass');
      rethrow;
    }
  }

  Future<SubjectResponse> fetchSubjects({
    required String classId,
    required String type,
  }) async {
    try {
      debugPrint("👉 Fetching subjects for classId=$classId, type=$type");
      final response = await ApiService.post('/getsubjects', {
        'class_id': classId,
        'type': type,
      });
      debugPrint("✅ fetchSubjects response: ${response.data}");
      return SubjectResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e, 'fetchSubjects');
      rethrow;
    }
  }

  Future<ChapterResponse> fetchChapter({
    required String subjectId,
    required String type,
  }) async {
    try {
      debugPrint("👉 Fetching chapters for subjectId=$subjectId, type=$type");
      final response = await ApiService.post('/getchapter', {
        'subject_id': subjectId,
        'type': type,
      });
      debugPrint("✅ fetchChapter response: ${response.data}");
      return ChapterResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e, 'fetchChapter');
      rethrow;
    }
  }

  Future<ChapterDetailsResponse> fetchChapterDetails({
    required String chapterId,
    required String type,
  }) async {
    try {
      debugPrint(
          "👉 Fetching chapter details for chapterId=$chapterId, type=$type");
      final response = await ApiService.post('/getchapter_details', {
        'chapter_id': chapterId,
        'type': type,
      });
      debugPrint("✅ fetchChapterDetails response: ${response.data}");
      return ChapterDetailsResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e, 'fetchChapterDetails');
      rethrow;
    }
  }

  void _handleError(DioError e, String methodName) {
    debugPrint("❌ Error in $methodName");
    debugPrint(e.toString());
    if (e.response != null) {
      debugPrint("❌ Server responded: ${e.response?.data}");
      throw Exception('Error from server: ${e.response?.data}');
    } else {
      debugPrint("❌ Network error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }
}

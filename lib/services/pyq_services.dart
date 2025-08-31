import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/pyq_modals.dart/pyq_class_response_modal.dart';

import 'package:urbantutorsapp/services/ApiService.dart';

class PyqServices {
  Future<ClassResponse> fetchClass({
    required String boardId,
    required String type,
  }) async {
    try {
      final response = await ApiService.post('/getclasses', {
        'board_id': boardId,
        'type': type,
      });
      return ClassResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Fetch subjects by class
  Future<SubjectResponse> fetchSubjects({
    required String classId,
    required String type,
  }) async {
    try {
      final response = await ApiService.post('/getsubjects', {
        'class_id': classId,
        'type': type,
      });
      return SubjectResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Fetch chapters by subject
  Future<ChapterResponse> fetchChapter({
    required String subjectId,
    required String type,
  }) async {
    try {
      final response = await ApiService.post('/getchapter', {
        'subject_id': subjectId,
        'type': type,
      });
      return ChapterResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Fetch chapter details
  Future<ChapterDetailsResponse> fetchChapterDetails({
    required String chapterId,
    required String type,
  }) async {
    try {
      final response = await ApiService.post('/getchapter_details', {
        'chapter_id': chapterId,
        'type': type,
      });
      return ChapterDetailsResponse.fromJson(response.data);
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioError e) {
    print("response from catch in PyqServices");
    print(e.toString());
    if (e.response != null) {
      throw Exception('Error from server: ${e.response?.data}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}

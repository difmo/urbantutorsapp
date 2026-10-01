import 'package:get/get.dart';
import 'package:urbantutorsapp/services/lead_meta_service.dart';

class LeadMetaController extends GetxController {
  final LeadMetaService _service = LeadMetaService();

  final classes = <LeadClass>[].obs;
  final subjects = <LeadSubject>[].obs;
  final chapters = <LeadChapter>[].obs;
  final chapterDetails = <ChapterDetail>[].obs;

  final isFetchingClasses = false.obs;
  final isFetchingSubjects = false.obs;
  final isFetchingChapters = false.obs;
  final isFetchingChapterDetails = false.obs;
  final error = ''.obs;

  Future<void> loadClasses(int boardId) async {
    await loadClassesForBoards([boardId]);
  }

  Future<void> loadClassesForBoards(List<int> boardIds) async {
    final validIds = boardIds.where((b) => b > 0).toSet().toList();
    if (validIds.isEmpty) return;
    try {
      error.value = '';
      isFetchingClasses.value = true;
      final results = await Future.wait(
        validIds.map((b) => _service.getClassesByBoard(b).catchError((_) => <LeadClass>[])),
      );
      final Map<int, LeadClass> merged = {};
      for (final list in results) {
        for (final c in list) {
          merged[c.classId] = c;
        }
      }
      classes.assignAll(merged.values.toList());
      print('Fetched classes for boards $validIds: ${classes.length}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingClasses.value = false;
    }
  }

  Future<void> loadSubjects1({required List<int> selClassIds,required List<int> selBoardIds}) async {
    try {
      error.value = '';
      isFetchingSubjects.value = true;
      subjects.clear();
      subjects.assignAll(await _service.getSubjectsByClassAndBoard1(
          selBoardIds: selBoardIds, selClassIds: selClassIds));
      print('Fetched subjects: ${subjects.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingSubjects.value = false;
    }
  }

  Future<void> loadSubjects(
      {required int classId, required int boardId}) async {
    try {
      error.value = '';
      isFetchingSubjects.value = true;
      subjects.clear();
      subjects.assignAll(await _service.getSubjectsByClassAndBoard(
          classId: classId, boardId: boardId));
      print('Fetched subjects: ${subjects.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingSubjects.value = false;
    }
  }

  Future<void> loadChapters(
      {required int subjectId, required String type}) async {
    try {
      error.value = '';
      isFetchingChapters.value = true;
      chapters.clear();
      chapters.assignAll(await _service.getChaptersBySubject(
          subjectId: subjectId, type: type));
      print('Fetched chapters: ${chapters.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingChapters.value = false;
    }
  }
}

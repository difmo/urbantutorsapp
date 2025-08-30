import 'package:get/get.dart';
import 'package:urbantutorsapp/services/lead_meta_service.dart';

class LeadMetaController extends GetxController {
  final LeadMetaService _service = LeadMetaService();

  final classes = <LeadClass>[].obs;
  final subjects = <LeadSubject>[].obs;

  final isFetchingClasses = false.obs;
  final isFetchingSubjects = false.obs;
  final error = ''.obs;

  Future<void> loadClasses(int boardId) async {
    try {
      error.value = '';
      isFetchingClasses.value = true;
      classes.clear();
      subjects.clear();
      classes.assignAll(await _service.getClassesByBoard(boardId));
      print('Fetched classes: ${classes.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingClasses.value = false;
    }
  }

  Future<void> loadSubjects({required int classId, required int boardId}) async {
    try {
      error.value = '';
      isFetchingSubjects.value = true;
      subjects.clear();
      subjects.assignAll(await _service.getSubjectsByClassAndBoard(classId: classId, boardId: boardId));
      print('Fetched subjects: ${subjects.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingSubjects.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/pyq_services.dart';
import 'package:urbantutorsapp/models/pyq_modals.dart/pyq_class_response_modal.dart'
    hide ChapterDetails;

class PyqController extends GetxController {
  final PyqServices _service = PyqServices();

  // Observables
  final boards = <BoardLead>[].obs;
  final classes = <ClassData>[].obs;
  final subjects = <SubjectData>[].obs;
  final chapters = <ChapterData>[].obs;
  final chapterDetails = Rxn<ChapterDetailsData>();

  // Loading states
  final loadingBoards = false.obs;
  final loadingClasses = false.obs;
  final loadingSubjects = false.obs;
  final loadingChapters = false.obs;
  final loadingDetails = false.obs;

  // Selected IDs
  final selectedBoardId = RxnInt();
  final selectedClassId = RxnInt();
  final selectedSubjectId = RxnInt();
  final selectedChapterId = RxnInt();

  // Error message
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBoards();
  }

  Future<void> fetchBoards() async {
    try {
      loadingBoards.value = true;
      errorMessage.value = '';
      // Boards usually come from MasterData
      // Mock here or fetch from API
      boards.assignAll([
        BoardLead(boardId: 1, boardLabel: "CBSE"),
        BoardLead(boardId: 2, boardLabel: "IB"),
        BoardLead(boardId: 3, boardLabel: "IGCSE"),
        BoardLead(boardId: 4, boardLabel: "ICSE"),
        BoardLead(boardId: 5, boardLabel: "ISC"),
        BoardLead(boardId: 6, boardLabel: "NIOS"),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loadingBoards.value = false;
    }
  }

  Future<void> fetchClasses(int boardId) async {
    try {
      loadingClasses.value = true;
      selectedBoardId.value = boardId;
      classes.clear();
      final res =
          await _service.fetchClass(boardId: boardId.toString(), type: "pyq");
      classes.assignAll(res.data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loadingClasses.value = false;
    }
  }

  Future<void> fetchSubjects(int classId) async {
    try {
      loadingSubjects.value = true;
      selectedClassId.value = classId;
      subjects.clear();
      final res = await _service.fetchSubjects(
          classId: classId.toString(), type: "pyq");
      subjects.assignAll(res.data as Iterable<SubjectData>);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loadingSubjects.value = false;
    }
  }

  Future<void> fetchChapters(int subjectId) async {
    try {
      loadingChapters.value = true;
      selectedSubjectId.value = subjectId;
      chapters.clear();
      final res = await _service.fetchChapter(
          subjectId: subjectId.toString(), type: 'pyq');
      chapters.assignAll((res.data) as Iterable<ChapterData>);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loadingChapters.value = false;
    }
  }

  Future<void> fetchChapterDetails(int chapterId) async {
    try {
      loadingDetails.value = true;
      selectedChapterId.value = chapterId;
      final res = await _service.fetchChapterDetails(
        chapterId: chapterId.toString(),
        type: 'pyq',
      );

      if (res.success) {
        chapterDetails.value = res.data;
      }
    } catch (e) {
      print("error fetch chapter");
      print(e.toString());
      errorMessage.value = e.toString();
    } finally {
      loadingDetails.value = false;
    }
  }

  
}

import 'package:get/get.dart';
import 'package:urbantutorsapp/models/student/ClassModel.dart';
import 'package:urbantutorsapp/models/student/chapter_detail_model.dart';
import 'package:urbantutorsapp/models/student/chapter_model.dart.dart';
import 'package:urbantutorsapp/models/student/subject_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class StudentController extends GetxController {
  final api = ApiService();

  var classes = <ClassModel>[].obs;
  var subjects = <SubjectModel>[].obs;
  var chapters = <ChapterModel>[].obs;
  var chapterDetails = Rxn<ChapterDetailsModel>();

  var isLoading = false.obs;

Future<void> loadClasses(String boardId, String type) async {
  isLoading.value = true;
  try {
    final data = await api.getClasses(boardId: boardId, type: type);
    classes.value = data.map<ClassModel>((e) => ClassModel.fromJson(e)).toList();
  } finally {
    isLoading.value = false;
  }
}


  Future<void> loadSubjects(String classId, String type) async {
    isLoading.value = true;
    try {
      final data = await api.getSubjects(classId: classId, type: type);
      subjects.value = data.map<SubjectModel>((e) => SubjectModel.fromJson(e)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChapters(String subjectId, String type) async {
    isLoading.value = true;
    try {
      final data = await api.getChapters(subjectId: subjectId, type: type);
      chapters.value = data.map<ChapterModel>((e) => ChapterModel.fromJson(e)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChapterDetails(String chapterId, String type) async {
    isLoading.value = true;
    try {
      final data = await api.getChapterDetails(chapterId: chapterId, type: type);
      chapterDetails.value = ChapterDetailsModel.fromJson(data);
    } finally {
      isLoading.value = false;
    }
  }
}

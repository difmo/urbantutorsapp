class NotesClass {
  final int id;
  final String name;
  NotesClass({required this.id, required this.name});

  factory NotesClass.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    String _name(Map<String, dynamic> m) => (m['class_name'] ??
            m['course_name'] ??
            m['boardclass_name'] ??
            m['name'] ??
            '')
        .toString();

    return NotesClass(
      id: _id(j['class_id'] ?? j['boardclass_id'] ?? j['id']),
      name: _name(j),
    );
  }
}

class NotesSubject {
  final int id;
  final String name;
  NotesSubject({required this.id, required this.name});

  factory NotesSubject.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    String _name(Map<String, dynamic> m) => (m['subject_name'] ??
            m['subjectName'] ??
            m['boardsubject_name'] ??
            m['name'] ??
            '')
        .toString();

    return NotesSubject(
      id: _id(j['subject_id'] ?? j['boardsubject_id'] ?? j['id']),
      name: _name(j),
    );
  }
}

class NotesChapter {
  final int id;
  final String name;
  NotesChapter({required this.id, required this.name});

  factory NotesChapter.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return NotesChapter(
      id: _id(j['chapter_id'] ?? j['id']),
      name:
          (j['ChapterName'] ?? j['chapter_name'] ?? j['name'] ?? '').toString(),
    );
  }
}

class ChapterDetailItem {
  final int id;
  final String heading; // heding_name
  final String image; // filename
  final String content;
  ChapterDetailItem(
      {required this.id,
      required this.heading,
      required this.image,
      required this.content});

  factory ChapterDetailItem.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return ChapterDetailItem(
      id: _id(j['id']),
      heading: (j['heding_name'] ?? j['heading_name'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      content: (j['content'] ?? '').toString(),
    );
  }
}

class ChapterDetails {
  final String boardName;
  final String className;
  final String subjectName;
  final String chapterName;
  final String imageBaseUrl; // imageurl
  final List<ChapterDetailItem> items;

  ChapterDetails({
    required this.boardName,
    required this.className,
    required this.subjectName,
    required this.chapterName,
    required this.imageBaseUrl,
    required this.items,
  });

  factory ChapterDetails.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>;
    final list = (data['chapter_detail'] as List<dynamic>? ?? [])
        .map((e) => ChapterDetailItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChapterDetails(
      boardName: (data['boardName'] ?? '').toString(),
      className: (data['className'] ?? '').toString(),
      subjectName: (data['subjectName'] ?? '').toString(),
      chapterName: (data['chapterName'] ?? '').toString(),
      imageBaseUrl: (data['imageurl'] ?? '').toString(),
      items: list,
    );
  }
}

class StudentProfile {
  final int id;
  final int leadId;
  final String studentName;
  final String? boardName;
  final String courseName;
  final String subjectName;
  final String mobile;
  final String price;
  final String? location;

  StudentProfile({
    required this.id,
    required this.leadId,
    required this.studentName,
    this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.mobile,
    required this.price,
    this.location,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'],
      leadId: json['lead_id'],
      studentName: json['student_name'],
      boardName: json['board_name'],
      courseName: json['course_name'],
      subjectName: json['subject_name'],
      mobile: json['mobile'].toString(),
      price: json['price'],
      location: json['location'],
    );
  }
}

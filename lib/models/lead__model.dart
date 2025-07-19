class StudentLeadResponse {
  final bool success;
  final List<StudentLead> data;
  final String message;

  StudentLeadResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory StudentLeadResponse.fromJson(Map<String, dynamic> json) {
    return StudentLeadResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((item) => StudentLead.fromJson(item))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class StudentLead {
  final int? id;
  final int? userId;
  final String studentName;
  final String boardName;
  final String courseName;
  final String subjectName;
  final int? mobile;
  final String price;
  final String state;
  final String location;
  final String mode;
  final String? typeOfTeacher;
  final String? remark;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentLead({
    this.id,
    this.userId,
    required this.studentName,
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    this.mobile,
    required this.price,
    required this.state,
    required this.location,
    required this.mode,
    this.typeOfTeacher,
    this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentLead.fromJson(Map<String, dynamic> json) {
    return StudentLead(
      id: json['id'],
      userId: json['user_id'],
      studentName: json['student_name'] ?? '',
      boardName: json['board_name'] ?? '',
      courseName: json['course_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      mobile: json['mobile'],
      price: json['price'] ?? '',
      state: json['state'] ?? '',
      location: json['location'] ?? '',
      mode: json['mode'] ?? '',
      typeOfTeacher: json['type_of_teacher'],
      remark: json['remark'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}

import 'package:urbantutorsapp/models/lead__model.dart';

class StudentLeadResponse {
  final bool success;
  final StudentLead data;
  final String message;

  StudentLeadResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory StudentLeadResponse.fromJson(Map<String, dynamic> json){
    return StudentLeadResponse(success: json['success'] ?? false, data: StudentLead.fromJson(json['data']), message: json['message'] ?? '',);
  }
}
class StudentLead {
  final int? id;
  final int? userId;
  final String? studentId;
  final String studentName;
  final String? boardId;
  final String? courseId;
  final String? subjectId;
  final String mobile;
  final String price;
  final String state;
  final String location;
  final String mode;
  final String? typeOfTeacher;
  final String? remark;
  final int? status;
  final int? leadStatus;
  final String? teacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentLead({
    this.id,
    this.userId,
    this.studentId,
    required this.studentName,
    this.boardId,
    this.courseId,
    this.subjectId,
    required this.mobile,
    required this.price,
    required this.state,
    required this.location,
    required this.mode,
    this.typeOfTeacher,
    this.remark,
    this.status,
    this.leadStatus,
    this.teacherId,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentLead.fromJson(Map<String, dynamic> json) {
    return StudentLead( id: json['id'],
      userId: int.tryParse(json['user_id'].toString()),
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
      boardId: json['board_id'],
      courseId: json['course_id'],
      subjectId: json['subject_id'],
      mobile: json['mobile'] ?? '',
      price: json['price'] ?? '',
      state: json['state'] ?? '',
      location: json['location'] ?? '',
      mode: json['mode'] ?? '',
      typeOfTeacher: json['type_of_teacher'],
      remark: json['remark'],
      status: json['status'],
      leadStatus: json['lead_status'],
      teacherId: json['teacher_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
          );
  }
}
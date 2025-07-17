class StudentProfileModel {
  final bool success;
  final StudentData? data;
  final String? message;

  StudentProfileModel({
    required this.success,
    this.data,
    this.message,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? StudentData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class StudentData {
  final int id;
  final int leadId;
  final String studentName;
  final String? boardName;
  final String courseName;
  final String subjectName;
  final int mobile;
  final String price;
  final double? latitude;
  final double? longitude;
  final String location;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentData({
    required this.id,
    required this.leadId,
    required this.studentName,
    this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.mobile,
    required this.price,
    this.latitude,
    this.longitude,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['id'],
      leadId: json['lead_id'],
      studentName: json['student_name'],
      boardName: json['board_name'],
      courseName: json['course_name'],
      subjectName: json['subject_name'],
      mobile: json['mobile'],
      price: json['price'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      location: json['location'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

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
  final int id;
  final int userId;
  final String studentName;
  final String studentId;
  final String boardName;
  final String courseName;
  final String subjectName;
  final String mobile;
  final String price;
  final String coins;
  final String leadCount;
  final String lead_status;
  final String lead_message;
  final String state;
  final String location;
  final String latitude;
  final String longitude;
  final String place_id;
  final String mode; // Online/Offline
  final String remark;
  final int share_status;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentLead({
    required this.id,
    required this.userId,
    required this.studentName,
    this.studentId = '',
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.coins,
    required this.leadCount,
    required this.lead_status,
    required this.lead_message,
    required this.remark,
    required this.share_status,
    required this.latitude,
    required this.longitude,
    required this.place_id,
    required this.mobile,
    required this.price,
    required this.state,
    required this.location,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentLead.fromJson(Map<String, dynamic> j) => StudentLead(
        id: j['id'] ?? 0,
        userId: j['user_id'] ?? 0,
        studentName: (j['student_name'] ?? '').toString(),
        studentId: (j['student_id'] ?? '').toString(),
        boardName: (j['board_name'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        subjectName: (j['subject_name'] ?? '').toString(),
        coins: (j['coins'] ?? '').toString(),
        leadCount: (j['lead_count'] ?? '').toString(),
        lead_status: (j['lead_status'] ?? '').toString(),
        lead_message: (j['lead_message'] ?? '').toString(),
        remark: (j['remark'] ?? '').toString(),
        share_status:(j['share_status']??0),
        latitude: (j['latitude'] ?? '').toString(),
        longitude: (j['longitude'] ?? '').toString(),
        place_id: (j['place_id'] ?? '').toString(),
    
        mobile: (j['mobile'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
        state: (j['state'] ?? '').toString(),
        location: (j['location'] ?? '').toString(),
        mode: (j['mode'] ?? '').toString(),
        status: j['status'] ?? 0,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
      );
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'student_name': studentName,
        'student_id': studentId,
        'board_name': boardName,
        'course_name': courseName,
        'subject_name': subjectName,
        'mobile': mobile,
        'price': price,
        'state': state,
        'location': location,
        'mode': mode,
        'status': status,
        'share_status':share_status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

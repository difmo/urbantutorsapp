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
        id: int.tryParse((j['id'] ?? j['lead_id'] ?? 0).toString()) ?? 0,
        userId: int.tryParse((j['user_id'] ?? 0).toString()) ?? 0,
        studentName: (j['student_name'] ?? j['studentName'] ?? j['name'] ?? '').toString(),
        studentId: (j['student_id'] ?? j['studentId'] ?? '').toString(),
        boardName: (j['board_name'] ?? j['board'] ?? j['board_label'] ?? j['board_lable'] ?? j['board_title'] ?? '').toString(),
        courseName: (j['course_name'] ?? j['course'] ?? j['class'] ?? j['class_name'] ?? '').toString(),
        subjectName: (j['subject_name'] ?? j['subjectname'] ?? j['subject'] ?? '').toString(),
        coins: (j['coins'] ?? j['coins_needed'] ?? j['coin'] ?? '').toString(),
        leadCount: _extractLeadCount(j),
        lead_status: (j['lead_status'] ?? '').toString(),
        lead_message: (j['lead_message'] ?? '').toString(),
        remark: (j['remark'] ?? j['remarks'] ?? j['note'] ?? j['notes'] ?? '').toString(),
        share_status: (j['share_status'] ?? 0),
        latitude: (j['latitude'] ?? '').toString(),
        longitude: (j['longitude'] ?? '').toString(),
        place_id: (j['place_id'] ?? '').toString(),
        mobile: (j['mobile'] ?? '').toString(),
        price: (j['price'] ?? j['fee'] ?? '').toString(),
        state: (j['state'] ?? '').toString(),
        location: (j['location'] ?? j['locality'] ?? '').toString(),
        mode: (j['mode'] ?? '').toString(),
        status: j['status'] ?? 0,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
      );

  static String _extractLeadCount(Map<String, dynamic> j) {
    const keys = [
      'lead_count',
      'max_tutors',
      'max_tutor',
      'max_hits',
      'leadCount',
      'lead_limit',
      'tutor_count',
      'hits',
      'max_lead',
    ];
    for (final k in keys) {
      final v = j[k];
      if (v != null) {
        final s = v.toString().trim();
        final n = int.tryParse(s);
        if (n != null && n > 0) return n.toString();
      }
    }
    for (final k in keys) {
      final v = j[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty && s != 'null' && s != '0') return s;
      }
    }
    return '1';
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'student_name': studentName,
        'student_id': studentId,
        'board_name': boardName,
        'board': boardName,
        'board_label': boardName,
        'board_lable': boardName,
        'course_name': courseName,
        'class': courseName,
        'subject_name': subjectName,
        'subject': subjectName,
        'mobile': mobile,
        'price': price,
        'fee': price,
        'coins': coins,
        'coins_needed': coins,
        'coin': coins,
        'lead_count': leadCount,
        'max_tutors': leadCount,
        'max_hits': leadCount,
        'leadCount': leadCount,
        'lead_status': lead_status,
        'lead_message': lead_message,
        'remark': remark,
        'remarks': remark,
        'note': remark,
        'notes': remark,
        'latitude': latitude,
        'longitude': longitude,
        'place_id': place_id,
        'state': state,
        'location': location,
        'mode': mode,
        'status': status,
        'share_status': share_status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

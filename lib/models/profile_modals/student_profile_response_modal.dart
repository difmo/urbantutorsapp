class StudentProfileResponsdModal {
  final bool success;
  final StudentProfileDataNew? data;
  final String message;

  StudentProfileResponsdModal({
    required this.success,
    this.data,
    required this.message,
  });

  factory StudentProfileResponsdModal.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponsdModal(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? StudentProfileDataNew.fromJson(json['data'])
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data?.toJson(),
      "message": message,
    };
  }
}

class StudentProfileDataNew {
  final int id;
  final int? profile_status;
  final String? profileId;
  final String? profile_picture;
  final int? leadStatus;
  final String? studentName;
  final String? mobile;
  final String? email;
  final String? totalCoins;
  final String? totalSpentCoins;
  final String? totalAvailableCoins;
  final String? boardName;
  final String? courseName;
  final String? subjectName;
  final String? price;
  final String? location;
  final String? state;
  final String? idType;
  final String? frontId;
  final String? frontBack;
  final String? remark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  StudentProfileDataNew({
    required this.id,
    this.profile_status,
    this.profile_picture,
    this.profileId,
    this.leadStatus,
    this.studentName,
    this.email,
    this.mobile,
    this.totalCoins,
    this.totalSpentCoins,
    this.totalAvailableCoins,
    this.boardName,
    this.courseName,
    this.subjectName,
    this.price,
    this.location,
    this.state,
    this.idType,
    this.frontId,
    this.frontBack,
    this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfileDataNew.fromJson(Map<String, dynamic> json) {
    return StudentProfileDataNew(
      id: json['id'] ?? 0,
      profile_status: json['profile_status'] ?? 0,
      profileId: json['profile_id'],
      profile_picture: json['profile_picture'],
      leadStatus: json['lead_status'],
      studentName: json['student_name'] ?? json['tutorbureau']??"test",
      mobile: json['mobile'] ?? json['tutorbureau_number']??"0000000000",
      totalCoins: json['total_coins']??"0",
      totalSpentCoins: json['total_spent_coins']??"1",
      totalAvailableCoins: json['total_Available_coins']??"10",
      boardName: json['board_name']??"",
      courseName: json['course_name']??"",
      subjectName: json['subject_name']??"",
      price: json['price']??"100",
      location: json['location']??"Test",
      state: json['state']??"test",
      email: json['email'] ?? "test@gmail.com",
      idType: json['idtype'],
      frontId: json['frontid'],
      frontBack: json['frontback'],
      remark: json['remark'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Null get total_Available_coins => null;

  Null get boardId => null;

  Null get courseId => null;

  Null get subjectId => null;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "profile_status": profile_status,
      "profile_id": profileId,
      "profile_picture": profile_picture,
      "lead_status": leadStatus,
      "student_name": studentName,
      "mobile": mobile,
      "total_coins": totalCoins,
      "total_spent_coins": totalSpentCoins,
      "total_Available_coins": totalAvailableCoins,
      "board_name": boardName,
      "course_name": courseName,
      "subject_name": subjectName,
      "price": price,
      "location": location,
      "state": state,
      "idtype": idType,
      "frontid": frontId,
      "frontback": frontBack,
      "remark": remark,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

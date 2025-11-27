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
  
  // Additional fields for proper data storage
  final int? boardId;
  final int? courseId;
  final int? subjectId;
  final int? pincode;
  final String? latitude;
  final String? longitude;
  final String? placeId;

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
    this.boardId,
    this.courseId,
    this.subjectId,
    this.pincode,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  factory StudentProfileDataNew.fromJson(Map<String, dynamic> json) {
    // Helper to parse int from dynamic
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return StudentProfileDataNew(
      id: json['id'] ?? 0,
      profile_status: json['profile_status'] ?? json['tutorburo_profile_status']??0,
      profileId: json['profile_id'],
      profile_picture: json['profile_picture'],
      leadStatus: json['lead_status'],
      studentName:
          json['student_name'] ?? json['tutorbureau'] ?? json['name'] ?? "test",
      mobile: json['mobile'] ?? json['tutorbureau_number'] ?? "0000000000",
      totalCoins: json['total_coins'] ?? "0",
      totalSpentCoins: json['total_spent_coins'] ?? "1",
      totalAvailableCoins: json['total_Available_coins'] ?? "10",
      boardName: json['board_name'] ?? "",
      courseName: json['course_name'] ?? "",
      subjectName: json['subject_name'] ?? "",
      price: json['price'] ?? "100",
      location: json['location'] ?? "Test",
      state: json['state'] ?? "test",
      email: json['email'] ?? "test@gmail.com",
      idType: json['idtype'],
      frontId: json['frontid'],
      frontBack: json['frontback'],
      remark: json['remark'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      boardId: parseInt(json['board_id']),
      courseId: parseInt(json['course_id']),
      subjectId: parseInt(json['subject_id']),
      pincode: parseInt(json['pincode']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      placeId: json['place_id']?.toString(),
    );
  }



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
      "board_id": boardId,
      "course_id": courseId,
      "subject_id": subjectId,
      "pincode": pincode,
      "latitude": latitude,
      "longitude": longitude,
      "place_id": placeId,
    };
  }
}

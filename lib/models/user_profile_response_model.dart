class UserProfileResponseModel {
  final bool success;
  final ProfileData data;
  final String message;

  UserProfileResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] ?? false,
      data: ProfileData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.toJson(),
      "message": message,
    };
  }
}

class ProfileData {
  final int id;
  final String? profileId;
  final String studentName;
  final String? boardName;
  final String? courseName;
  final String? subjectName;
  final String mobile;
  final String? price;
  final List<dynamic> location;
  final String? state;
  final String? idtype;
  final String? frontid;
  final String? frontback;
  final String? remark;
  final String status;
  final String createdAt;
  final String updatedAt;

  ProfileData({
    required this.id,
    required this.profileId,
    required this.studentName,
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.mobile,
    required this.price,
    required this.location,
    required this.state,
    required this.idtype,
    required this.frontid,
    required this.frontback,
    required this.remark,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      profileId: json['profile_id']?.toString(),
      studentName: json['student_name'] ?? '',
      boardName: json['board_name'],
      courseName: json['course_name'],
      subjectName: json['subject_name'],
      mobile: json['mobile'] ?? '',
      price: json['price']?.toString(),
      location: json['location'] != null ? List<dynamic>.from(json['location']) : [],
      state: json['state'],
      idtype: json['idtype'],
      frontid: json['frontid'],
      frontback: json['frontback'],
      remark: json['remark'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "profile_id": profileId,
      "student_name": studentName,
      "board_name": boardName,
      "course_name": courseName,
      "subject_name": subjectName,
      "mobile": mobile,
      "price": price,
      "location": location,
      "state": state,
      "idtype": idtype,
      "frontid": frontid,
      "frontback": frontback,
      "remark": remark,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

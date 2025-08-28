class UserProfileResponse {
  final bool success;
  final ProfileData data;
  final String message;

  UserProfileResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] ?? false,
      data: ProfileData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ProfileData {
  final int id;
  final String? profileId;
  final String? studentName;
  final String? boardName;
  final String? courseName;
  final String? subjectName;
  final String? mobile;
  final String? price;
  final List<dynamic> location;
  final String? state;
  final String? idType;
  final String? frontId;
  final String? frontBack;
  final String? remark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  ProfileData({
    required this.id,
    this.profileId,
    this.studentName,
    this.boardName,
    this.courseName,
    this.subjectName,
    this.mobile,
    this.price,
    required this.location,
    this.state,
    this.idType,
    this.frontId,
    this.frontBack,
    this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      profileId: json['profile_id'],
      studentName: json['student_name'],
      boardName: json['board_name'],
      courseName: json['course_name'],
      subjectName: json['subject_name'],
      mobile: json['mobile'],
      price: json['price']?.toString(),
      location: json['location'] ?? [],
      state: json['state'],
      idType: json['idtype'],
      frontId: json['frontid'],
      frontBack: json['frontback'],
      remark: json['remark'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

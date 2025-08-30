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
  final List<dynamic> profileId;
  final String? studentName;
  final String? mobile;
  final String? totalCoins;
  final String? totalSpentCoins;
  final String? totalAvailableCoins;
  final List<dynamic> boardName;
  final List<dynamic> courseName;
  final List<dynamic> subjectName;
  final List<dynamic> price;
  final List<dynamic> location;
  final List<dynamic> state;
  final List<dynamic> idType;
  final List<dynamic> frontId;
  final List<dynamic> frontBack;
  final List<dynamic> remark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  ProfileData({
    required this.id,
    required this.profileId,
    this.studentName,
    this.mobile,
    this.totalCoins,
    this.totalSpentCoins,
    this.totalAvailableCoins,
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.price,
    required this.location,
    required this.state,
    required this.idType,
    required this.frontId,
    required this.frontBack,
    required this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      profileId: json['profile_id'] ?? [],
      studentName: json['student_name'],
      mobile: json['mobile'],
      totalCoins: json['total_coins'],
      totalSpentCoins: json['total_spent_coins'],
      totalAvailableCoins: json['total_Available_coins'],
      boardName: json['board_name'] ?? [],
      courseName: json['course_name'] ?? [],
      subjectName: json['subject_name'] ?? [],
      price: json['price'] ?? [],
      location: json['location'] ?? [],
      state: json['state'] ?? [],
      idType: json['idtype'] ?? [],
      frontId: json['frontid'] ?? [],
      frontBack: json['frontback'] ?? [],
      remark: json['remark'] ?? [],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

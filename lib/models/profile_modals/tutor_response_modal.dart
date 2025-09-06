class TutorProfileResponse {
  final bool success;
  final TutorProfileData data;
  final String message;

  TutorProfileResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TutorProfileResponse.fromJson(Map<String, dynamic> json) {
    return TutorProfileResponse(
      success: json['success'] ?? false,
      data: TutorProfileData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class TutorProfileData {
  final int id;
  final int? profile_status;
  final String? profileId;
  final String? studentName;
  final String? mobile;
  final String? totalCoins;
  final String? totalSpentCoins;
  final String? totalAvailableCoins;
  final String? mostExperienceSubjectName;
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

  TutorProfileData({
    required this.id,
    this.profile_status,
    this.profileId,
    this.studentName,
    this.mobile,
    this.totalCoins,
    this.totalSpentCoins,
    this.totalAvailableCoins,
    this.mostExperienceSubjectName,
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

  factory TutorProfileData.fromJson(Map<String, dynamic> json) {
    return TutorProfileData(
      id: json['id'] ?? 0,
      profile_status: json['profile_status'] ?? 0,
      profileId: json['profile_id']?.toString(),
      studentName: json['student_name']?.toString(),
      mobile: json['mobile']?.toString(),
      totalCoins: json['total_coins']?.toString(),
      totalSpentCoins: json['total_spent_coins']?.toString(),
      totalAvailableCoins: json['total_Available_coins']?.toString(),
      mostExperienceSubjectName: json['mostexperiensubject_name']?.toString(),
      price: json['price']?.toString(),
      location: json['location']?.toString(),
      state: json['state']?.toString(),
      idType: json['idtype']?.toString(),
      frontId: json['frontid']?.toString(),
      frontBack: json['frontback']?.toString(),
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

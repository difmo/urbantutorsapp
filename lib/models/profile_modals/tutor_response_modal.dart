// tutor_profile_model.dart

class TutorProfileResponse {
  final bool success;
  final TutorProfileData? data;
  final String message;

  TutorProfileResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TutorProfileResponse.fromJson(Map<String, dynamic> json) {
    return TutorProfileResponse(
      success: json['success'] == true || json['success']?.toString() == '1',
      data: json['data'] != null && json['data'] is Map
          ? TutorProfileData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class TutorProfileData {
  final int id;
  final String? teacherName;
  final int? profileStatus;
  final String? profileId;
  final int? rating;
  final int? totalFeedbacks;
  final int? positionShow;
  final int? experienceYears;
  final String? fbLink;
  final String? frontId;
  final String? instaLink;
  final String? whLink;
  final String? email;
  final String? profilePicture;
  final String? mobile;
  final double? totalCoins;
  final double? totalSpentCoins;
  final double? totalAvailableCoins;
  final double? minAmount;
  final double? maxAmount;
  final String? location;
  final String ? pincode;

  final String? placeId;
  final double? latitude;
  final double? longitude;
  final String? state;
  final String? idType;
  final String? frontBack;
  final String? remark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<TeachingDetails> teachingDetails;
  final String? mode;


  TutorProfileData({
    required this.id,
    this.teacherName,
    this.profileStatus,
    this.profileId,
    this.rating,
    this.totalFeedbacks,
    this.positionShow,
    this.experienceYears,
    this.fbLink,
    this.frontId,
    this.instaLink,
    this.whLink,
    this.email,
    this.profilePicture,
    this.mobile,
    this.totalCoins,
    this.totalSpentCoins,
    this.totalAvailableCoins,
    this.minAmount,
    this.maxAmount,
    this.location,
    this.placeId,
    this.latitude,
    this.longitude,
    this.state,
    this.idType,
    this.frontBack,
    this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.teachingDetails = const [],
    this.mode,
    this.pincode
  });

  // --- helpers to parse robustly ---
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static List<TeachingDetails> _parseTeachingDetails(dynamic td) {
    if (td == null) return <TeachingDetails>[];
    if (td is List) {
      return td
          .where((e) => e != null)
          .map((e) =>
              TeachingDetails.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (td is Map) {
      return [TeachingDetails.fromJson(Map<String, dynamic>.from(td))];
    }
    return <TeachingDetails>[];
  }

  factory TutorProfileData.fromJson(Map<String, dynamic> json) {
    return TutorProfileData(
      id: _parseInt(json['id']) ?? 0,
      teacherName: json['teacher_name']?.toString(),
      profileStatus: _parseInt(json['profile_status']),
      profileId: json['profile_id']?.toString(),
      rating: _parseInt(json['rating']),
      totalFeedbacks: _parseInt(json['total_feedbacks']),
      positionShow: _parseInt(json['positionShow']),
      experienceYears: _parseInt(json['experience_years']),
      fbLink: json['fb_link']?.toString(),
      frontId: json['frontid']?.toString(),
      instaLink: json['insta_link']?.toString(),
      whLink: json['wh_link']?.toString(),
      email: json['email']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      mobile: json['mobile']?.toString(),
      totalCoins: _parseDouble(json['total_coins']),
      totalSpentCoins: _parseDouble(json['total_spent_coins']),
      totalAvailableCoins: _parseDouble(json['total_Available_coins']),
      minAmount: _parseDouble(json['min_amount']),
      maxAmount: _parseDouble(json['max_amount']),
      location: json['location']?.toString(),
      placeId: json['place_id']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      state: json['state']?.toString(),
      idType: json['idtype']?.toString(),
      frontBack: json['frontback']?.toString(),
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      teachingDetails:
          _parseTeachingDetails(json['teaching_details'] ?? json['teachingDetails']),
             mode: json['mode']?.toString(),
            pincode:json['pincode']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_name': teacherName,
      'profile_status': profileStatus,
      'profile_id': profileId,
      'rating': rating,
      'total_feedbacks': totalFeedbacks,
      'positionShow': positionShow,
      'experience_years': experienceYears,
      'fb_link': fbLink,
      'frontid': frontId,
      'insta_link': instaLink,
      'wh_link': whLink,
      'email': email,
      'profile_picture': profilePicture,
      'mobile': mobile,
      'total_coins': totalCoins?.toString(),
      'total_spent_coins': totalSpentCoins?.toString(),
      'total_Available_coins': totalAvailableCoins?.toString(),
      'min_amount': minAmount?.toString(),
      'max_amount': maxAmount?.toString(),
      'location': location,
      'place_id': placeId,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'state': state,
      'idtype': idType,
      'frontback': frontBack,
      'remark': remark,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teaching_details': teachingDetails.map((e) => e.toJson()).toList(),
       'mode': mode,
       'pincode':pincode
    };
  }
}

class TeachingDetails {
  final int? boardId;
  final String? boardName;
  final int? classId;
  final String? className;
  final int? subjectId;
  final String? subjectName;

  TeachingDetails({
    this.boardId,
    this.boardName,
    this.classId,
    this.className,
    this.subjectId,
    this.subjectName,
  });

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory TeachingDetails.fromJson(Map<String, dynamic> json) {
    return TeachingDetails(
      boardId: _parseInt(json['board_id']),
      boardName: json['board_name']?.toString(),
      classId: _parseInt(json['class_id']),
      className: json['class_name']?.toString(),
      subjectId: _parseInt(json['subject_id']),
      subjectName: json['subject_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'board_name': boardName,
      'class_id': classId,
      'class_name': className,
      'subject_id': subjectId,
      'subject_name': subjectName,
    };
  }
}

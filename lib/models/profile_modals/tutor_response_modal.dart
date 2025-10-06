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
      success: json['success'] == true,
      data: json['data'] != null
          ? TutorProfileData.fromJson(json['data'] as Map<String, dynamic>)
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
  final String? rating;
  final String? totalFeedbacks;
  final String? positionShow;
  final String? profilePicture;
  final String? mobile;
  final String? email;
  final String? totalCoins;
  final String? totalSpentCoins;
  final String? totalAvailableCoins;
  final String? minAmount;
  final String? maxAmount;

  final String? location;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final String? state;
  final String? idType;
  final String? frontId;
  final String? frontBack;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? remark;

  final List<TeachingDetails> teachingDetails;
  final String? mostExperienceSubjectName;
  final String? price;

  TutorProfileData({
    required this.id,
    this.teacherName,
    this.profileStatus,
    this.profileId,
    this.rating,
    this.totalFeedbacks,
    this.positionShow,
    this.profilePicture,
    this.mobile,
    this.email,
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
    this.frontId,
    this.frontBack,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.remark,
    this.teachingDetails = const [],
    this.mostExperienceSubjectName,
    this.price,
  });

  factory TutorProfileData.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s);
    }

    List<TeachingDetails> parseTeachingDetails(dynamic td) {
      if (td == null) return <TeachingDetails>[];
      if (td is List) {
        return td
            .where((e) => e != null)
            .map((e) => TeachingDetails.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <TeachingDetails>[];
    }

    return TutorProfileData(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      teacherName: json['teacher_name']?.toString(),
      profileStatus: json['profile_status'] is int
          ? json['profile_status'] as int
          : int.tryParse(json['profile_status']?.toString() ?? ''),
      profileId: json['profile_id']?.toString(),
      rating: json['rating']?.toString(),
      totalFeedbacks: json['total_feedbacks']?.toString(),
      positionShow:
          json['positionShow']?.toString() ?? json['positionShow']?.toString(),
      profilePicture: json['profile_picture']?.toString() ??
          json['profile_picture']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email'] ?? "test@gmail.com",
      totalCoins: json['total_coins']?.toString(),
      totalSpentCoins: json['total_spent_coins']?.toString(),
      totalAvailableCoins: json['total_Available_coins']?.toString() ??
          json['total_Available_coins']?.toString(),
      minAmount: json['min_amount']?.toString(),
      maxAmount: json['max_amount']?.toString(),
      location: json['location']?.toString(),
      placeId: json['place_id']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      state: json['state']?.toString(),
      idType: json['idtype']?.toString(),
      frontId: json['frontid']?.toString(),
      frontBack: json['frontback']?.toString(),
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      teachingDetails: parseTeachingDetails(json['teaching_details']),
      mostExperienceSubjectName: json['mostexperiensubject_name']?.toString(),
      price: json['price']?.toString(),
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
      'profile_picture': profilePicture,
      'mobile': mobile,
      'total_coins': totalCoins,
      'total_spent_coins': totalSpentCoins,
      'total_Available_coins': totalAvailableCoins,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'location': location,
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'idtype': idType,
      'frontid': frontId,
      'frontback': frontBack,
      'remark': remark,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teaching_details': teachingDetails.map((e) => e.toJson()).toList(),
      'mostexperiensubject_name': mostExperienceSubjectName,
      'price': price,
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

  factory TeachingDetails.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return TeachingDetails(
      boardId: parseInt(json['board_id']),
      boardName: json['board_name']?.toString(),
      classId: parseInt(json['class_id']),
      className: json['class_name']?.toString(),
      subjectId: parseInt(json['subject_id']),
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

  static List<TeachingDetails> listFromJson(List<dynamic>? jsonList) {
    if (jsonList == null) return <TeachingDetails>[];
    return jsonList
        .where((e) => e != null)
        .map((e) => TeachingDetails.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

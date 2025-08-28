class StudentProfileResponse {
  final bool success;
  final StudentProfileData? data;
  final String message;

  StudentProfileResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory StudentProfileResponse.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? StudentProfileData.fromJson(json['data']) : null,
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

class StudentProfileData {
  final int id;
  final int userId;
  final String profilePicture;
  final int boardId;
  final int courseId;
  final int subjectId;
  final int? mostExperienceSubjectsId;
  final int price;
  final String location;
  final String state;
  final String idType;
  final String frontId;
  final String frontBack;
  final String remark;
  final String createdAt;
  final String updatedAt;

  StudentProfileData({
    required this.id,
    required this.userId,
    required this.profilePicture,
    required this.boardId,
    required this.courseId,
    required this.subjectId,
    this.mostExperienceSubjectsId,
    required this.price,
    required this.location,
    required this.state,
    required this.idType,
    required this.frontId,
    required this.frontBack,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      profilePicture: json['profile_picture'] ?? '',
      boardId: json['board_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      mostExperienceSubjectsId: json['mostexperiensubjects_id'],
      price: json['price'] ?? 0,
      location: json['location'] ?? '',
      state: json['state'] ?? '',
      idType: json['idtype'] ?? '',
      frontId: json['frontid'] ?? '',
      frontBack: json['frontback'] ?? '',
      remark: json['remark'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "profile_picture": profilePicture,
      "board_id": boardId,
      "course_id": courseId,
      "subject_id": subjectId,
      "mostexperiensubjects_id": mostExperienceSubjectsId,
      "price": price,
      "location": location,
      "state": state,
      "idtype": idType,
      "frontid": frontId,
      "frontback": frontBack,
      "remark": remark,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

class StudentProfileUpdateRequest {
  final int userId;
  final int boardId;
  final int courseId;
  final int subjectId;
  final int price;
  final String location;
  final String state;
  final String idType;
  final String remark;
  final String profilePicture; // base64
  final String frontId;        // base64
  final String frontBack;      // base64

  StudentProfileUpdateRequest({
    required this.userId,
    required this.boardId,
    required this.courseId,
    required this.subjectId,
    required this.price,
    required this.location,
    required this.state,
    required this.idType,
    required this.remark,
    required this.profilePicture,
    required this.frontId,
    required this.frontBack,
  });

  factory StudentProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return StudentProfileUpdateRequest(
      userId: json['user_id'] ?? 0,
      boardId: json['board_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      price: json['price'] ?? 0,
      location: json['location'] ?? '',
      state: json['state'] ?? '',
      idType: json['idtype'] ?? '',
      remark: json['remark'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      frontId: json['frontid'] ?? '',
      frontBack: json['frontback'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "board_id": boardId,
      "course_id": courseId,
      "subject_id": subjectId,
      "price": price,
      "location": location,
      "state": state,
      "idtype": idType,
      "remark": remark,
      "profile_picture": profilePicture,
      "frontid": frontId,
      "frontback": frontBack,
    };
  }
}

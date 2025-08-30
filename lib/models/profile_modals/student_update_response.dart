class StudentUpdateResponse {
  final bool success;
  final StudentProfileDataNew? data;
  final String message;

  StudentUpdateResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory StudentUpdateResponse.fromJson(Map<String, dynamic> json) {
    return StudentUpdateResponse(
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
  final int? userId;
  final String? profilePicture;
  final int? boardId;
  final int? courseId;
  final int? subjectId;
  final int? mostExperienceSubjectsId;
  final int? price;
  final String? location;
  final String? state;
  final String? idType;
  final String? frontId;
  final String? frontBack;
  final String? remark;
  final String? createdAt;
  final String? updatedAt;

  StudentProfileDataNew({
    required this.id,
    this.userId,
    this.profilePicture,
    this.boardId,
    this.courseId,
    this.subjectId,
    this.mostExperienceSubjectsId,
    this.price,
    this.location,
    this.state,
    this.idType,
    this.frontId,
    this.frontBack,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfileDataNew.fromJson(Map<String, dynamic> json) {
    return StudentProfileDataNew(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      profilePicture: json['profile_picture'],
      boardId: json['board_id'],
      courseId: json['course_id'],
      subjectId: json['subject_id'],
      mostExperienceSubjectsId: json['mostexperiensubjects_id'],
      price: json['price'],
      location: json['location'],
      state: json['state'],
      idType: json['idtype'],
      frontId: json['frontid'],
      frontBack: json['frontback'],
      remark: json['remark'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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

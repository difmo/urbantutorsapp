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
      success: json['success'] == true,
      data: (json['data'] is Map<String, dynamic>)
          ? StudentProfileDataNew.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class StudentProfileDataNew {
  final int id;
  final int? userId;
  final String? roleType;
  final String? profilePicture;
  final int? boardId;
  final int? courseId;
  final int? subjectId;
  final int? price;
  final String? location;
  final String? placeId;     // camelCase in code
  final String? latitude;    // keep as String, but coerce properly
  final String? longitude;
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
    this.roleType,
    this.profilePicture,
    this.boardId,
    this.courseId,
    this.subjectId,
    this.price,
    this.location,
    this.placeId,
    this.latitude,
    this.longitude,
    this.state,
    this.idType,
    this.frontId,
    this.frontBack,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  // ---- helper casters ----
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  factory StudentProfileDataNew.fromJson(Map<String, dynamic> json) {
    return StudentProfileDataNew(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['user_id']),
      roleType: _asString(json['roleType']),
      profilePicture: _asString(json['profile_picture']),
      boardId: _asInt(json['board_id']),
      courseId: _asInt(json['course_id']),
      subjectId: _asInt(json['subject_id']),
      price: _asInt(json['price']),
      location: _asString(json['location']),
      placeId: _asString(json['place_id']),
      latitude: _asString(json['latitude']),
      longitude: _asString(json['longitude']),
      state: _asString(json['state']),
      idType: _asString(json['idtype']),
      frontId: _asString(json['frontid']),
      frontBack: _asString(json['frontback']),
      remark: _asString(json['remark']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "roleType": roleType,
        "profile_picture": profilePicture,
        "board_id": boardId,
        "course_id": courseId,
        "subject_id": subjectId,
        "price": price,
        "location": location,
        "place_id": placeId,
        "latitude": latitude,
        "longitude": longitude,
        "state": state,
        "idtype": idType,
        "frontid": frontId,
        "frontback": frontBack,
        "remark": remark,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

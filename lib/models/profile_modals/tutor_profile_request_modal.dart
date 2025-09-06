class TutorProfileUpdateRequest {
  final int userId;
  final int mostExperienSubjectsId;
  final double price;
  final String location;
  final String state;
  final String idType;
  final String remark;
  final String profilePicture; // base64 string
  final String frontId; // base64 string
  final String frontBack; // base64 string

  TutorProfileUpdateRequest({
    required this.userId,
    required this.mostExperienSubjectsId,
    required this.price,
    required this.location,
    required this.state,
    required this.idType,
    required this.remark,
    required this.profilePicture,
    required this.frontId,
    required this.frontBack,
    required int boardId,
    required int courseId,
    required int subjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "mostexperiensubjects_id": mostExperienSubjectsId,
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

  factory TutorProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return TutorProfileUpdateRequest(
      userId: json["user_id"],
      mostExperienSubjectsId: json["mostexperiensubjects_id"],
      price: (json["price"] as num).toDouble(),
      location: json["location"],
      state: json["state"],
      idType: json["idtype"],
      remark: json["remark"],
      profilePicture: json["profile_picture"],
      frontId: json["frontid"],
      frontBack: json["frontback"],
      boardId: json["board_id"],
      courseId: json["course_id"],
      subjectId: json["subject_id"],
    );
  }
}

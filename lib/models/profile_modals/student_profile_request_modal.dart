class StudentProfileUpdateRequest {
  final int userId;
  final int boardId;
  final int courseId;
  final int subjectId;
  final double price;
  final String location;
  final String state;
  final String idType;
  final String remark;
  final String profilePicture; // base64 string
  final String frontId; // base64 string
  final String frontBack; // base64 string

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

  factory StudentProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return StudentProfileUpdateRequest(
      userId: json["user_id"],
      boardId: json["board_id"],
      courseId: json["course_id"],
      subjectId: json["subject_id"],
      price: (json["price"] as num).toDouble(),
      location: json["location"],
      state: json["state"],
      idType: json["idtype"],
      remark: json["remark"],
      profilePicture: json["profile_picture"],
      frontId: json["frontid"],
      frontBack: json["frontback"],
    );
  }
}

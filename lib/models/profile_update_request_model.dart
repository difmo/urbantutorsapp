class ProfileUpdateRequest {
  final int userId;
  final int boardId;
  final int courseId;
  final int subjectId;
  final int price;
  final String location;
  final String state;
  final String idType;
  final String remark;
  final String? profilePicture; // base64 string
  final String? frontId;        // base64 string
  final String? backId;         // base64 string

  ProfileUpdateRequest({
    required this.userId,
    required this.boardId,
    required this.courseId,
    required this.subjectId,
    required this.price,
    required this.location,
    required this.state,
    required this.idType,
    required this.remark,
    this.profilePicture,
    this.frontId,
    this.backId,
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
      "frontback": backId, // API expects "frontback"
    };
  }
}

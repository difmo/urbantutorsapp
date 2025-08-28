class LeadCreateRequest {
  final String name;
  final String mobile;
  final String boardId;
  final String classId;
  final String location;
  final String state;
  final String mode;
  final String fee;
  final String leadId;
  final String subjectId;
  final String userId;
  final String tutorGender;
  final String maxHits;
  final String supportAgent;

  LeadCreateRequest({
    required this.name,
    required this.mobile,
    required this.boardId,
    required this.classId,
    required this.location,
    required this.state,
    required this.mode,
    required this.fee,
    required this.leadId,
    required this.subjectId,
    required this.userId,
    required this.tutorGender,
    required this.maxHits,
    required this.supportAgent,
  });

  /// ✅ Corrected method name and added all fields
  Map<String, dynamic> toFormData() {
    return {
      'name': name,
      'mobile': mobile,
      'board_id': boardId,
      'class_id': classId,
      'location': location,
      'state': state,
      'mode': mode,
      'fee': fee,
      'lead_id': leadId,
      'subject_id': subjectId,
      'user_id': userId,
      'tutor_gender': tutorGender,
      'max_hits': maxHits,
      'support_agent': supportAgent,
    };
  }
}

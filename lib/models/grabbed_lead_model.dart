class GrabLead {
  final int grabLeadId;
  final int leadId;
  final int fakeLeadStatus;
  final String? fakeLeadMessage;
  final String leadOwnerName;
  final String leadOwnerNumber;
  final String studentId;
  final String studentName;
  final String studentMobile;
  final String boardName;
  final String courseName;
  final String subjectName;
  final String price;
  final String location;
  final String placeId;
  final String state;
  final String latitude;
  final String longitude;
  final String coins;
  final String mode;
  final String remark;
  final String? fakeLeadRemark;
  final String teacherName;
  final String teacherMobile;

  GrabLead({
    required this.grabLeadId,
    required this.leadId,
    required this.fakeLeadStatus,
    this.fakeLeadMessage,
    required this.leadOwnerName,
    required this.leadOwnerNumber,
    required this.studentId,
    required this.studentName,
    required this.studentMobile,
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.price,
    required this.location,
    required this.placeId,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.coins,
    required this.mode,
    required this.remark,
    this.fakeLeadRemark,
    required this.teacherName,
    required this.teacherMobile,
  });

  factory GrabLead.fromJson(Map<String, dynamic> j) => GrabLead(
        grabLeadId: j['grab_lead_id'] ?? 0,
        leadId: j['lead_id'] ?? 0,
        fakeLeadStatus: j['fake_lead_status'] ?? 0,
        fakeLeadMessage: j['fake_lead_massage'],
        leadOwnerName: (j['lead_wonner_name'] ?? '').toString(),
        leadOwnerNumber: (j['lead_wonner_number'] ?? '').toString(),
        studentId: (j['student_id'] ?? '').toString(),
        studentName: (j['student_name'] ?? '').toString(),
        studentMobile: (j['student_mobile'] ?? '').toString(),
        boardName: (j['board_name'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        subjectName: (j['subjectname'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
        location: (j['location'] ?? '').toString(),
        placeId: (j['place_id'] ?? '').toString(),
        state: (j['state'] ?? '').toString(),
        latitude: (j['latitude'] ?? '').toString(),
        longitude: (j['longitude'] ?? '').toString(),
        coins: (j['coins'] ?? '').toString(),
        mode: (j['mode'] ?? '').toString(),
        remark: (j['remark'] ?? '').toString(),
        fakeLeadRemark: j['fake_lead_remark']?.toString(),
        teacherName: (j['teacher_name'] ?? '').toString(),
        teacherMobile: (j['teacher_moblie'] ?? '').toString(),
      );
  Map<String, dynamic> toJson() => {
        'grab_lead_id': grabLeadId,
        'lead_id': leadId,
        'fake_lead_status': fakeLeadStatus,
        if (fakeLeadMessage != null) 'fake_lead_massage': fakeLeadMessage,
        'lead_wonner_name': leadOwnerName,
        'lead_wonner_number': leadOwnerNumber,
        'student_id': studentId,
        'student_name': studentName,
        'student_mobile': studentMobile,
        'board_name': boardName,
        'course_name': courseName,
        'subjectname': subjectName,
        'price': price,
        'location': location,
        'place_id': placeId,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'coins': coins,
        'mode': mode,
        'remark': remark,
        if (fakeLeadRemark != null) 'fake_lead_remark': fakeLeadRemark,
        'teacher_name': teacherName,
        'teacher_moblie': teacherMobile,
      };
}

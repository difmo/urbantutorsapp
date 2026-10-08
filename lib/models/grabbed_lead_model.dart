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

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _resolvePhone(Map<String, dynamic> j) {
    final candidates = [
      j['mobile'],
      j['student_mobile'],
      j['student_mobile_no'],
      j['student_phone'],
      j['phone'],
      j['contact'],
    ];
    for (final c in candidates) {
      if (c != null) {
        final s = c.toString().trim();
        if (s.isNotEmpty && s != 'null' && s != '0' && s != '—') {
          return s;
        }
      }
    }
    return '';
  }

  factory GrabLead.fromJson(Map<String, dynamic> j) => GrabLead(
        grabLeadId: _asInt(j['grab_lead_id']),
        leadId: _asInt(j['lead_id']),
        fakeLeadStatus: _asInt(j['fake_lead_status']),
        fakeLeadMessage: j['fake_lead_massage'],
        leadOwnerName: (j['lead_wonner_name'] ?? j['lead_owner_name'] ?? '').toString(),
        leadOwnerNumber: (j['lead_wonner_number'] ?? j['lead_owner_number'] ?? '').toString(),
        studentId: (j['student_id'] ?? '').toString(),
        studentName: (j['student_name'] ?? j['name'] ?? '').toString(),
        studentMobile: _resolvePhone(j),
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

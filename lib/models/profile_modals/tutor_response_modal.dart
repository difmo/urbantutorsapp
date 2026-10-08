// tutor_profile_model.dart
import 'dart:convert';

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
      success: json['success'] == true || json['success']?.toString() == '1',
      data: json['data'] != null && json['data'] is Map
          ? TutorProfileData.fromJson(Map<String, dynamic>.from(json['data']))
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
  final int? rating;
  final int? totalFeedbacks;
  final int? positionShow;
  final int? experienceYears;
  final String? fbLink;
  final String? frontId;
  final String? instaLink;
  final String? whLink;
  final String? email;
  final String? profilePicture;
  final String? mobile;
  final double? totalCoins;
  final double? totalSpentCoins;
  final double? totalAvailableCoins;
  final double? minAmount;
  final double? maxAmount;
  final String? location;
  final String? pincode;

  final String? placeId;
  final double? latitude;
  final double? longitude;
  final String? state;
  final String? idType;
  final String? frontBack;
  final String? remark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<TeachingDetails> teachingDetails;
  final String? mode;
  final String? qualification;

  TutorProfileData({
    required this.id,
    this.teacherName,
    this.profileStatus,
    this.profileId,
    this.rating,
    this.totalFeedbacks,
    this.positionShow,
    this.experienceYears,
    this.fbLink,
    this.frontId,
    this.instaLink,
    this.whLink,
    this.email,
    this.profilePicture,
    this.mobile,
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
    this.frontBack,
    this.remark,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.teachingDetails = const [],
    this.mode,
    this.pincode,
    this.qualification,
  });

  // --- helpers to parse robustly ---
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v ? 1 : 0;
    if (v is int) return v;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true') return 1;
      if (s == 'false') return 0;
      return int.tryParse(s);
    }
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static List<TeachingDetails> _parseTeachingDetails(dynamic td) {
    if (td == null) return <TeachingDetails>[];
    if (td is String) {
      final trimmed = td.trim();
      if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _parseTeachingDetails(decoded);
        } catch (_) {}
      }
    }
    if (td is List) {
      return td
          .where((e) => e != null)
          .map((e) {
            if (e is TeachingDetails) return e;
            if (e is Map) {
              return TeachingDetails.fromJson(Map<String, dynamic>.from(e));
            }
            return TeachingDetails();
          })
          .where((e) => e.boardId != null || e.classId != null || e.subjectId != null)
          .toList();
    }
    if (td is Map) {
      return [TeachingDetails.fromJson(Map<String, dynamic>.from(td))];
    }
    return <TeachingDetails>[];
  }

  static String? _pickValidName(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isEmpty) continue;
      final lower = s.toLowerCase();
      if (lower == 'null' ||
          lower == 'user' ||
          lower == 'urban user' ||
          lower == 'tutor') {
        continue;
      }
      return s;
    }
    return null;
  }

  factory TutorProfileData.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map
        ? json['user'] as Map
        : (json['userData'] is Map ? json['userData'] as Map : null);

    final parsedTd = _parseTeachingDetails(
        json['teaching_details'] ??
        json['teachingDetails'] ??
        userObj?['teaching_details'] ??
        userObj?['teachingDetails']);

    List<TeachingDetails> effectiveTd = List.from(parsedTd);
    final rawB = json['board_id'] ?? json['board_ids'] ?? json['boards'] ?? userObj?['board_id'] ?? userObj?['board_ids'];
    final rawC = json['class_id'] ?? json['class_ids'] ?? json['classes'] ?? json['course_id'] ?? json['course_ids'] ?? userObj?['class_id'] ?? userObj?['class_ids'];
    final rawS = json['subject_id'] ?? json['subject_ids'] ?? json['subjects'] ?? userObj?['subject_id'] ?? userObj?['subject_ids'];
    final List<int> bList = _extractIdList(rawB);
    final List<int> cList = _extractIdList(rawC);
    final List<int> sList = _extractIdList(rawS);

    if (effectiveTd.isEmpty) {
      if (bList.isNotEmpty || cList.isNotEmpty || sList.isNotEmpty) {
        final List<TeachingDetails> syn = [];
        final bSafe = bList.isNotEmpty ? bList : [0];
        final cSafe = cList.isNotEmpty ? cList : [0];
        final sSafe = sList.isNotEmpty ? sList : [0];
        for (final b in bSafe) {
          for (final c in cSafe) {
            for (final s in sSafe) {
              syn.add(TeachingDetails(
                boardId: b > 0 ? b : null,
                classId: c > 0 ? c : null,
                subjectId: s > 0 ? s : null,
              ));
            }
          }
        }
        effectiveTd = syn;
      }
    } else {
      // Also ensure any classes or subjects from raw lists not yet represented are preserved
      final existingClassIds = effectiveTd.map((e) => e.classId).whereType<int>().toSet();
      final existingSubjectIds = effectiveTd.map((e) => e.subjectId).whereType<int>().toSet();
      int? defaultBoard;
      for (final e in effectiveTd) {
        if (e.boardId != null) {
          defaultBoard = e.boardId;
          break;
        }
      }
      defaultBoard ??= (bList.isNotEmpty ? bList.first : null);

      final existingBoardIds = effectiveTd.map((e) => e.boardId).whereType<int>().toSet();
      for (final b in bList) {
        if (!existingBoardIds.contains(b)) {
          effectiveTd.add(TeachingDetails(boardId: b, classId: cList.isNotEmpty ? cList.first : null, subjectId: sList.isNotEmpty ? sList.first : null));
          existingBoardIds.add(b);
        }
      }
      for (final c in cList) {
        if (!existingClassIds.contains(c)) {
          effectiveTd.add(TeachingDetails(boardId: defaultBoard, classId: c, subjectId: sList.isNotEmpty ? sList.first : null));
          existingClassIds.add(c);
        }
      }
      for (final s in sList) {
        if (!existingSubjectIds.contains(s)) {
          effectiveTd.add(TeachingDetails(boardId: defaultBoard, classId: cList.isNotEmpty ? cList.first : null, subjectId: s));
          existingSubjectIds.add(s);
        }
      }
    }
    final rawName = _pickValidName([
      json['teacher_name'],
      json['teacherName'],
      json['name'],
      json['full_name'],
      json['fullName'],
      json['user_name'],
      json['userName'],
      json['tutor_name'],
      userObj?['teacher_name'],
      userObj?['teacherName'],
      userObj?['name'],
      userObj?['full_name'],
      userObj?['fullName'],
      userObj?['user_name'],
      userObj?['userName'],
      userObj?['tutor_name'],
    ]);

    final teacherObj = json['teacher'] is Map
        ? json['teacher'] as Map
        : (json['teacherData'] is Map ? json['teacherData'] as Map : null);

    int? resolvedStatus = _parseInt(json['profile_status']) ??
        _parseInt(userObj?['profile_status']) ??
        _parseInt(teacherObj?['profile_status']) ??
        _parseInt(json['profileStatus']) ??
        _parseInt(userObj?['profileStatus']) ??
        _parseInt(teacherObj?['profileStatus']);

    final isVerifiedFlag = _parseInt(json['is_verified']) ??
        _parseInt(userObj?['is_verified']) ??
        _parseInt(teacherObj?['is_verified']) ??
        _parseInt(json['is_verify']) ??
        _parseInt(userObj?['is_verify']) ??
        _parseInt(teacherObj?['is_verify']) ??
        _parseInt(json['verified']) ??
        _parseInt(userObj?['verified']) ??
        _parseInt(teacherObj?['verified']) ??
        _parseInt(json['verify']) ??
        _parseInt(userObj?['verify']) ??
        _parseInt(teacherObj?['verify']);

    final rawStatusStr = (json['status'] ??
            userObj?['status'] ??
            teacherObj?['status'] ??
            json['teacher_status'])
        ?.toString()
        .trim()
        .toLowerCase();

    final bool isApprovedOnServer = isVerifiedFlag == 1 ||
        resolvedStatus == 2 ||
        rawStatusStr == '2' ||
        rawStatusStr == 'verified' ||
        rawStatusStr == 'approved';

    if (isApprovedOnServer) {
      resolvedStatus = 2;
    } else if (resolvedStatus == 1 ||
        rawStatusStr == 'pending' ||
        rawStatusStr == 'under_verification' ||
        rawStatusStr == '0' ||
        isVerifiedFlag == 0) {
      resolvedStatus = 1;
    } else if (resolvedStatus == 0) {
      resolvedStatus = 0;
    }

    return TutorProfileData(
      id: _parseInt(json['id']) ?? 0,
      teacherName: rawName,
      profileStatus: resolvedStatus,
      profileId: json['profile_id']?.toString(),
      rating: _parseInt(json['rating']),
      totalFeedbacks: _parseInt(json['total_feedbacks']),
      positionShow: _parseInt(json['positionShow']),
      experienceYears: _parseInt(json['experience_years']),
      fbLink: json['fb_link']?.toString(),
      frontId: (json['frontid'] ??
              json['front_id'] ??
              json['frontId'] ??
              json['id_card'] ??
              json['idcard'] ??
              json['identity_card'] ??
              json['id_proof'] ??
              userObj?['frontid'] ??
              userObj?['front_id'] ??
              userObj?['id_card'] ??
              userObj?['identity_card'])
          ?.toString(),
      instaLink: json['insta_link']?.toString(),
      whLink: json['wh_link']?.toString(),
      email: json['email']?.toString(),
      profilePicture: (json['profile_picture'] ??
              json['profile_image'] ??
              json['image'] ??
              json['photo'] ??
              json['avatar'] ??
              userObj?['profile_picture'] ??
              userObj?['profile_image'] ??
              userObj?['image'] ??
              userObj?['photo'] ??
              userObj?['avatar'])
          ?.toString(),
      mobile: json['mobile']?.toString(),
      totalCoins: _parseDouble(json['total_coins']),
      totalSpentCoins: _parseDouble(json['total_spent_coins']),
      totalAvailableCoins: _parseDouble(json['total_Available_coins']),
      minAmount: _parseDouble(json['min_amount']),
      maxAmount: _parseDouble(json['max_amount']),
      location: json['location']?.toString(),
      placeId: json['place_id']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      state: json['state']?.toString(),
      idType: (json['idtype'] ?? json['idType'] ?? userObj?['idtype'] ?? userObj?['idType'])?.toString(),
      frontBack: (json['frontback'] ??
              json['backid'] ??
              json['back_id'] ??
              json['backId'] ??
              json['front_back'] ??
              json['id_back'] ??
              userObj?['frontback'] ??
              userObj?['backid'] ??
              userObj?['back_id'] ??
              userObj?['id_back'])
          ?.toString(),
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      teachingDetails: effectiveTd,
      mode: (json['mode'] ??
              json['teaching_mode'] ??
              json['teachingMode'] ??
              json['mode_of_teaching'] ??
              json['class_mode'] ??
              userObj?['mode'] ??
              userObj?['teaching_mode'] ??
              userObj?['teachingMode'] ??
              userObj?['mode_of_teaching'])
          ?.toString(),
      pincode: json['pincode']?.toString(),
      qualification: json['qualification']?.toString(),
    );
  }

  static List<int> _extractIdList(dynamic val) {
    if (val == null) return [];
    if (val is int) return val > 0 ? [val] : [];
    if (val is String) {
      final s = val.trim();
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final decoded = jsonDecode(s);
          return _extractIdList(decoded);
        } catch (_) {}
      }
      return s
          .split(',')
          .map((part) => int.tryParse(part.trim()))
          .whereType<int>()
          .where((i) => i > 0)
          .toList();
    }
    if (val is Iterable) {
      return val
          .map((e) => e is int ? e : int.tryParse(e.toString()))
          .whereType<int>()
          .where((i) => i > 0)
          .toSet()
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_name': teacherName,
      'teacherName': teacherName,
      'name': teacherName,
      'full_name': teacherName,
      'fullName': teacherName,
      'user_name': teacherName,
      'userName': teacherName,
      'tutor_name': teacherName,
      'profile_status': profileStatus,
      'profile_id': profileId,
      'rating': rating,
      'total_feedbacks': totalFeedbacks,
      'positionShow': positionShow,
      'experience_years': experienceYears,
      'fb_link': fbLink,
      'frontid': frontId,
      'front_id': frontId,
      'insta_link': instaLink,
      'wh_link': whLink,
      'email': email,
      'profile_picture': profilePicture,
      'mobile': mobile,
      'total_coins': totalCoins?.toString(),
      'total_spent_coins': totalSpentCoins?.toString(),
      'total_Available_coins': totalAvailableCoins?.toString(),
      'min_amount': minAmount?.toString(),
      'max_amount': maxAmount?.toString(),
      'location': location,
      'place_id': placeId,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'state': state,
      'idtype': idType,
      'idType': idType,
      'frontback': frontBack,
      'backid': frontBack,
      'back_id': frontBack,
      'remark': remark,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teaching_details': teachingDetails.map((e) => e.toJson()).toList(),
      'mode': mode,
      'teaching_mode': mode,
      'teachingMode': mode,
      'pincode': pincode,
      'qualification': qualification,
    };
  }

  TutorProfileData copyWith({
    int? id,
    String? teacherName,
    int? profileStatus,
    String? profileId,
    int? rating,
    int? totalFeedbacks,
    int? positionShow,
    int? experienceYears,
    String? fbLink,
    String? frontId,
    String? instaLink,
    String? whLink,
    String? email,
    String? profilePicture,
    String? mobile,
    double? totalCoins,
    double? totalSpentCoins,
    double? totalAvailableCoins,
    double? minAmount,
    double? maxAmount,
    String? location,
    String? placeId,
    double? latitude,
    double? longitude,
    String? state,
    String? idType,
    String? frontBack,
    String? remark,
    String? status,
    String? createdAt,
    String? updatedAt,
    List<TeachingDetails>? teachingDetails,
    String? mode,
    String? qualification,
    String? pincode,
  }) {
    return TutorProfileData(
      id: id ?? this.id,
      teacherName: teacherName ?? this.teacherName,
      profileStatus: profileStatus ?? this.profileStatus,
      profileId: profileId ?? this.profileId,
      rating: rating ?? this.rating,
      totalFeedbacks: totalFeedbacks ?? this.totalFeedbacks,
      positionShow: positionShow ?? this.positionShow,
      experienceYears: experienceYears ?? this.experienceYears,
      fbLink: fbLink ?? this.fbLink,
      frontId: frontId ?? this.frontId,
      instaLink: instaLink ?? this.instaLink,
      whLink: whLink ?? this.whLink,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      mobile: mobile ?? this.mobile,
      totalCoins: totalCoins ?? this.totalCoins,
      totalSpentCoins: totalSpentCoins ?? this.totalSpentCoins,
      totalAvailableCoins: totalAvailableCoins ?? this.totalAvailableCoins,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      location: location ?? this.location,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
      idType: idType ?? this.idType,
      frontBack: frontBack ?? this.frontBack,
      remark: remark ?? this.remark,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      teachingDetails: teachingDetails ?? this.teachingDetails,
      mode: mode ?? this.mode,
      qualification: qualification ?? this.qualification,
      pincode: pincode ?? this.pincode,
    );
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

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory TeachingDetails.fromJson(Map<String, dynamic> json) {
    return TeachingDetails(
      boardId: _parseInt(json['board_id'] ?? json['boardId']),
      boardName: (json['board_name'] ?? json['boardName'] ?? json['board_lable'] ?? json['name'])?.toString(),
      classId: _parseInt(json['class_id'] ?? json['classId'] ?? json['course_id'] ?? json['courseId']),
      className: (json['class_name'] ?? json['className'] ?? json['ClassName'] ?? json['course_name'])?.toString(),
      subjectId: _parseInt(json['subject_id'] ?? json['subjectId']),
      subjectName: (json['subject_name'] ?? json['subjectName'] ?? json['subjectname'] ?? json['name'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'boardId': boardId,
      'board_name': boardName,
      'boardName': boardName,
      'board_label': boardName,
      'class_id': classId,
      'classId': classId,
      'course_id': classId,
      'courseId': classId,
      'class_name': className,
      'className': className,
      'course_name': className,
      'courseName': className,
      'subject_id': subjectId,
      'subjectId': subjectId,
      'subject_name': subjectName,
      'subjectName': subjectName,
      'subjectname': subjectName,
      'name': subjectName,
      'status': 1,
      'is_verify': 1,
    };
  }
}

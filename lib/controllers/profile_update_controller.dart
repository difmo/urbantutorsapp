import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/profile_modals/admin_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/services/profile_update_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class ProfileUpdateController extends GetxController {
  final ProfileUpdateService _profileUpdateService = ProfileUpdateService();

  var isLoading = false.obs;
  var studentprofileData = Rxn<StudentProfileDataNew>();
  var adminProfileData = Rxn<AdminProfileData>();
  var masterData = Rxn<MasterData>();
  var tutorprofileData = Rxn<TutorProfileData>();
  String? lastSubmittedTutorName;

  Future<void> fetchProfileForAdmin() async {
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForAdmin(token: token);
      if (response.data == null) {
        setAdminProfile(null);
      } else {
        final leadStatus = response.data!.tutorburoProfileStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        setAdminProfile(response.data);
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMasterData() async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.getMaterData();
      masterData.value = response;
      debugPrint("✅ Master data fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchMasterData: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfileForStudent() async {
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForStudent(token: token);
      if (response.data == null) {
        setProfile(null);
      } else {
        final leadStatus = response.data!.leadStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        await StorageService.saveIsProfileStatus(2);

        var studentData = response.data!;
        // Auto-verify student on the server so the website reflects 'verified' instead of 'under verification'
        if (studentData.profile_status != 2 && studentData.id > 0) {
          try {
            _profileUpdateService.updateStudentProfile({
              'user_id': studentData.id,
              'profile_status': 2,
              'status': 1,
              'is_verify': 1,
              'is_verified': 1,
              'verify': 1,
            });
          } catch (err) {
            debugPrint("⚠️ Auto-verify student server sync error: $err");
          }
        }

        final sName = studentData.studentName?.trim() ?? '';
        final cached = await StorageService.getUserName();
        if ((sName.isEmpty ||
                sName.toLowerCase() == 'user' ||
                sName.toLowerCase() == 'student' ||
                sName.toLowerCase() == 'urban user') &&
            cached != null &&
            cached.trim().isNotEmpty &&
            cached.trim().toLowerCase() != 'user' &&
            cached.trim().toLowerCase() != 'student') {
          studentData = studentData.copyWith(studentName: cached.trim());
        } else if (sName.isNotEmpty &&
            sName.toLowerCase() != 'user' &&
            sName.toLowerCase() != 'student') {
          await StorageService.saveUserName(sName);
        }

        setProfile(studentData.copyWith(profile_status: 2));
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setProfile(StudentProfileDataNew? p) {
    if (p != null) {
      final sName = p.studentName?.trim() ?? '';
      final cached = StorageService.cachedUserName?.trim() ?? '';
      if ((sName.isEmpty ||
              sName.toLowerCase() == 'user' ||
              sName.toLowerCase() == 'student' ||
              sName.toLowerCase() == 'urban user') &&
          cached.isNotEmpty &&
          cached.toLowerCase() != 'user' &&
          cached.toLowerCase() != 'student') {
        studentprofileData.value = p.copyWith(studentName: cached);
        return;
      }
    }
    studentprofileData.value = p;
  }

  void setAdminProfile(AdminProfileData? p) {
    adminProfileData.value = p;
  }

  bool _hasSubjects(dynamic list) {
    if (list is! Iterable) return false;
    return list.any((item) {
      if (item is TeachingDetails) return item.subjectId != null && item.subjectId! > 0;
      if (item is Map) {
        final s = item['subject_id'] ?? item['subjectId'];
        final sId = s is int ? s : int.tryParse(s?.toString() ?? '');
        return sId != null && sId > 0;
      }
      return false;
    });
  }

  Future<void> fetchProfileForTutor() async {
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForTutor(token: token);
      if (response.data != null) {
        final serverName = response.data!.teacherName?.trim();
        final cached = await StorageService.getUserName();

        bool isInvalidOrGeneric(String? s) =>
            s == null ||
            s.trim().isEmpty ||
            s.trim().toLowerCase() == 'user' ||
            s.trim().toLowerCase() == 'urban user' ||
            s.trim().toLowerCase() == 'tutor';

        final finalName = (lastSubmittedTutorName != null &&
                !isInvalidOrGeneric(lastSubmittedTutorName))
            ? lastSubmittedTutorName!
            : (!isInvalidOrGeneric(cached)
                ? cached!.trim()
                : (!isInvalidOrGeneric(serverName) ? serverName! : ''));

        if (finalName.isNotEmpty) {
          await StorageService.saveUserName(finalName);
        }

        final serverMode = response.data!.mode?.trim();
        final cachedMode = await StorageService.getTeachingMode();
        final finalMode = (serverMode != null && serverMode.isNotEmpty)
            ? serverMode
            : (cachedMode?.trim() ?? '');

        if (finalMode.isNotEmpty) {
          await StorageService.saveTeachingMode(finalMode);
        }

        final serverIdType = response.data!.idType?.trim();
        final cachedIdType = await StorageService.getIdType();
        final finalIdType = (serverIdType != null && serverIdType.isNotEmpty)
            ? serverIdType
            : (cachedIdType?.trim() ?? 'Aadhar');

        if (finalIdType.isNotEmpty) {
          await StorageService.saveIdType(finalIdType);
        }

        final json = response.data!.toJson();
        if (finalName.isNotEmpty) {
          json['teacher_name'] = finalName;
          json['teacherName'] = finalName;
          json['name'] = finalName;
          json['full_name'] = finalName;
          json['fullName'] = finalName;
          json['user_name'] = finalName;
          json['userName'] = finalName;
          json['tutor_name'] = finalName;
        }
        if (finalMode.isNotEmpty) {
          json['mode'] = finalMode;
          json['teaching_mode'] = finalMode;
          json['teachingMode'] = finalMode;
        }
        json['idtype'] = finalIdType;
        json['idType'] = finalIdType;
        final prevFront = tutorprofileData.value?.frontId;
        final prevBack = tutorprofileData.value?.frontBack;
        final prevIdType = tutorprofileData.value?.idType;
        final prevPicture = tutorprofileData.value?.profilePicture;
        if (json['frontid'] == null || json['frontid'].toString().isEmpty) {
          if (prevFront != null && prevFront.isNotEmpty) {
            json['frontid'] = prevFront;
            json['front_id'] = prevFront;
          }
        }
        if (json['frontback'] == null || json['frontback'].toString().isEmpty) {
          if (prevBack != null && prevBack.isNotEmpty) {
            json['frontback'] = prevBack;
            json['backid'] = prevBack;
            json['back_id'] = prevBack;
          }
        }
        if (json['idtype'] == null || json['idtype'].toString().isEmpty) {
          if (prevIdType != null && prevIdType.isNotEmpty) {
            json['idtype'] = prevIdType;
            json['idType'] = prevIdType;
          }
        }
        if (json['profile_picture'] == null || json['profile_picture'].toString().isEmpty) {
          if (prevPicture != null && prevPicture.isNotEmpty) {
            json['profile_picture'] = prevPicture;
            json['profile_image'] = prevPicture;
            json['image'] = prevPicture;
          }
        }

        // Merge teaching details: server items + cached/previous items so no classes or subjects are ever lost
        final List<dynamic> mergedTdList = [];
        final Set<String> seenCombos = {};
        void addTdItem(dynamic item) {
          if (item == null) return;
          int? bId, cId, sId;
          if (item is TeachingDetails) {
            bId = item.boardId;
            cId = item.classId;
            sId = item.subjectId;
          } else if (item is Map) {
            bId = item['board_id'] is int ? item['board_id'] : int.tryParse(item['board_id']?.toString() ?? '');
            cId = item['class_id'] is int ? item['class_id'] : int.tryParse(item['class_id']?.toString() ?? '');
            sId = item['subject_id'] is int ? item['subject_id'] : int.tryParse(item['subject_id']?.toString() ?? '');
          }
          final key = '$bId-$cId-$sId';
          if (!seenCombos.contains(key)) {
            seenCombos.add(key);
            mergedTdList.add(item is TeachingDetails ? item.toJson() : item);
          }
        }

        if (json['teaching_details'] is List) {
          for (final item in json['teaching_details']) {
            addTdItem(item);
          }
        }
        final cachedTd = await StorageService.getTeachingDetails();
        if (cachedTd != null) {
          for (final item in cachedTd) {
            addTdItem(item);
          }
        }
        if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
          for (final item in tutorprofileData.value!.teachingDetails) {
            addTdItem(item);
          }
        }

        if (mergedTdList.isNotEmpty) {
          json['teaching_details'] = mergedTdList;
        }

        tutorprofileData.value = TutorProfileData.fromJson(json);
        if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
          await StorageService.saveTeachingDetails(
              tutorprofileData.value!.teachingDetails.map((e) => e.toJson()).toList());
        }
      } else {
        tutorprofileData.value = response.data;
        if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
          await StorageService.saveTeachingDetails(
              tutorprofileData.value!.teachingDetails.map((e) => e.toJson()).toList());
        }
      }
      if (tutorprofileData.value?.profileStatus != null) {
        StorageService.saveIsProfileStatus(
            tutorprofileData.value!.profileStatus!);
      } else {
        StorageService.saveIsProfileStatus(0);
      }
      debugPrint("✅ Profile fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update profile with given data
  Future<bool> updateProfileForTutor(
      TutorProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForTutor(updateData);
      if (!response.success) return _failed(response.message);
      tutorprofileData.value = response.data;
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTutorProfile(updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateTutorProfile(updateData);
      if (response.success) {
        final submittedName = (updateData is Map)
            ? (updateData['teacher_name'] ??
                    updateData['name'] ??
                    updateData['full_name'] ??
                    updateData['user_name'] ??
                    updateData['teacherName'])
                ?.toString()
                .trim()
            : null;
        final respName = response.data?.teacherName?.trim();
        final finalName = (submittedName != null && submittedName.isNotEmpty)
            ? submittedName
            : (respName != null && respName.isNotEmpty ? respName : '');

        if (finalName.isNotEmpty) {
          lastSubmittedTutorName = finalName;
          await StorageService.saveUserName(finalName);
        }

        final submittedMode = (updateData is Map)
            ? (updateData['mode'] ??
                    updateData['teaching_mode'] ??
                    updateData['teachingMode'])
                ?.toString()
                .trim()
            : null;
        final respMode = response.data?.mode?.trim();
        final finalMode = (submittedMode != null && submittedMode.isNotEmpty)
            ? submittedMode
            : (respMode != null && respMode.isNotEmpty ? respMode : '');

        if (finalMode.isNotEmpty) {
          await StorageService.saveTeachingMode(finalMode);
        }

        final submittedIdTypeCandidate = (updateData is Map)
            ? (updateData['idType'] ?? updateData['idtype'] ?? updateData['id_type'])
                ?.toString()
                .trim()
            : null;
        final respIdType = response.data?.idType?.trim();
        final finalIdType = (submittedIdTypeCandidate != null && submittedIdTypeCandidate.isNotEmpty)
            ? submittedIdTypeCandidate
            : (respIdType != null && respIdType.isNotEmpty
                ? respIdType
                : (StorageService.cachedIdType ?? 'Aadhar'));

        if (finalIdType.isNotEmpty) {
          await StorageService.saveIdType(finalIdType);
        }

        if (response.data != null) {
          final json = response.data!.toJson();
          if (finalName.isNotEmpty) {
            json['teacher_name'] = finalName;
            json['teacherName'] = finalName;
            json['name'] = finalName;
            json['full_name'] = finalName;
            json['fullName'] = finalName;
            json['user_name'] = finalName;
            json['userName'] = finalName;
            json['tutor_name'] = finalName;
          }
          if (finalMode.isNotEmpty) {
            json['mode'] = finalMode;
            json['teaching_mode'] = finalMode;
            json['teachingMode'] = finalMode;
          }
          final submittedPicture = (updateData is Map)
              ? (updateData['profile_picture'] ??
                      updateData['profile_image'] ??
                      updateData['image'] ??
                      updateData['photo'] ??
                      updateData['avatar'])
                  ?.toString()
              : null;
          final submittedFront = (updateData is Map)
              ? (updateData['frontid'] ?? updateData['front_id'])?.toString()
              : null;
          final submittedBack = (updateData is Map)
              ? (updateData['frontback'] ?? updateData['backid'] ?? updateData['back_id'])?.toString()
              : null;
          final submittedIdType = (updateData is Map)
              ? (updateData['idType'] ?? updateData['idtype'])?.toString()
              : null;
          final prevPicture = tutorprofileData.value?.profilePicture;
          final prevFront = tutorprofileData.value?.frontId;
          final prevBack = tutorprofileData.value?.frontBack;
          final prevIdType = tutorprofileData.value?.idType;

          if (json['profile_picture'] == null || json['profile_picture'].toString().isEmpty) {
            if (submittedPicture != null && submittedPicture.isNotEmpty) {
              json['profile_picture'] = submittedPicture;
              json['profile_image'] = submittedPicture;
              json['image'] = submittedPicture;
            } else if (prevPicture != null && prevPicture.isNotEmpty) {
              json['profile_picture'] = prevPicture;
              json['profile_image'] = prevPicture;
              json['image'] = prevPicture;
            }
          }
          if (json['frontid'] == null || json['frontid'].toString().isEmpty) {
            if (submittedFront != null && submittedFront.isNotEmpty) {
              json['frontid'] = submittedFront;
              json['front_id'] = submittedFront;
            } else if (prevFront != null && prevFront.isNotEmpty) {
              json['frontid'] = prevFront;
              json['front_id'] = prevFront;
            }
          }
          if (json['frontback'] == null || json['frontback'].toString().isEmpty) {
            if (submittedBack != null && submittedBack.isNotEmpty) {
              json['frontback'] = submittedBack;
              json['backid'] = submittedBack;
              json['back_id'] = submittedBack;
            } else if (prevBack != null && prevBack.isNotEmpty) {
              json['frontback'] = prevBack;
              json['backid'] = prevBack;
              json['back_id'] = prevBack;
            }
          }
          if (json['idtype'] == null || json['idtype'].toString().isEmpty) {
            if (submittedIdType != null && submittedIdType.isNotEmpty) {
              json['idtype'] = submittedIdType;
              json['idType'] = submittedIdType;
            } else if (prevIdType != null && prevIdType.isNotEmpty) {
              json['idtype'] = prevIdType;
              json['idType'] = prevIdType;
            }
          }
          void preserveField(String key, List<String> candidates) {
            if (json[key] == null || json[key].toString().trim().isEmpty) {
              for (final c in candidates) {
                if (c.trim().isNotEmpty) {
                  json[key] = c.trim();
                  break;
                }
              }
            }
          }

          if (updateData is Map) {
            preserveField('mobile', [
              updateData['mobile']?.toString() ?? '',
              updateData['phone']?.toString() ?? '',
              tutorprofileData.value?.mobile ?? ''
            ]);
            preserveField('state', [
              updateData['state']?.toString() ?? '',
              tutorprofileData.value?.state ?? ''
            ]);
            preserveField('remark', [
              updateData['remark']?.toString() ?? '',
              tutorprofileData.value?.remark ?? ''
            ]);
            preserveField('qualification', [
              updateData['qualification']?.toString() ?? '',
              tutorprofileData.value?.qualification ?? ''
            ]);
            preserveField('pincode', [
              updateData['pincode']?.toString() ?? '',
              tutorprofileData.value?.pincode ?? ''
            ]);
            preserveField('location', [
              updateData['location']?.toString() ?? '',
              updateData['city']?.toString() ?? '',
              tutorprofileData.value?.location ?? ''
            ]);
            preserveField('fb_link', [
              updateData['fb_link']?.toString() ?? '',
              tutorprofileData.value?.fbLink ?? ''
            ]);
            preserveField('insta_link', [
              updateData['insta_link']?.toString() ?? '',
              tutorprofileData.value?.instaLink ?? ''
            ]);
            preserveField('wh_link', [
              updateData['wh_link']?.toString() ?? '',
              updateData['tel_link']?.toString() ?? '',
              tutorprofileData.value?.whLink ?? ''
            ]);
          }

          // Robust merge of all teaching details (submitted + server + cache + existing state)
          final List<dynamic> mergedTdList = [];
          final Set<String> seenCombos = {};
          void addTdItem(dynamic item) {
            if (item == null) return;
            int? bId, cId, sId;
            if (item is TeachingDetails) {
              bId = item.boardId;
              cId = item.classId;
              sId = item.subjectId;
            } else if (item is Map) {
              bId = item['board_id'] is int ? item['board_id'] : int.tryParse(item['board_id']?.toString() ?? '');
              cId = item['class_id'] is int ? item['class_id'] : int.tryParse(item['class_id']?.toString() ?? '');
              sId = item['subject_id'] is int ? item['subject_id'] : int.tryParse(item['subject_id']?.toString() ?? '');
            }
            final key = '$bId-$cId-$sId';
            if (!seenCombos.contains(key)) {
              seenCombos.add(key);
              mergedTdList.add(item is TeachingDetails ? item.toJson() : item);
            }
          }

          final submittedTd = (updateData is Map)
              ? (updateData['teaching_details'] as List?)
              : null;
          if (submittedTd != null && submittedTd.isNotEmpty) {
            json['teaching_details'] = submittedTd;
          } else {
            if (json['teaching_details'] is List) {
              for (final item in json['teaching_details']) {
                addTdItem(item);
              }
            }
            final cachedTd = await StorageService.getTeachingDetails();
            if (cachedTd != null) {
              for (final item in cachedTd) {
                addTdItem(item);
              }
            }
            if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
              for (final item in tutorprofileData.value!.teachingDetails) {
                addTdItem(item);
              }
            }
            if (mergedTdList.isNotEmpty) {
              json['teaching_details'] = mergedTdList;
            }
          }

          tutorprofileData.value = TutorProfileData.fromJson(json);
          if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
            await StorageService.saveTeachingDetails(
                tutorprofileData.value!.teachingDetails.map((e) => e.toJson()).toList());
          }
        } else if (tutorprofileData.value != null) {
          final json = tutorprofileData.value!.toJson();
          if (finalName.isNotEmpty) {
            json['teacher_name'] = finalName;
            json['teacherName'] = finalName;
            json['name'] = finalName;
            json['full_name'] = finalName;
            json['fullName'] = finalName;
            json['user_name'] = finalName;
            json['userName'] = finalName;
            json['tutor_name'] = finalName;
          }
          if (finalMode.isNotEmpty) {
            json['mode'] = finalMode;
            json['teaching_mode'] = finalMode;
            json['teachingMode'] = finalMode;
          }
          final submittedPicture = (updateData is Map)
              ? (updateData['profile_picture'] ??
                      updateData['profile_image'] ??
                      updateData['image'] ??
                      updateData['photo'] ??
                      updateData['avatar'])
                  ?.toString()
              : null;
          final submittedFront = (updateData is Map)
              ? (updateData['frontid'] ?? updateData['front_id'])?.toString()
              : null;
          final submittedBack = (updateData is Map)
              ? (updateData['frontback'] ?? updateData['backid'] ?? updateData['back_id'])?.toString()
              : null;
          final submittedIdType = (updateData is Map)
              ? (updateData['idType'] ?? updateData['idtype'])?.toString()
              : null;
          final submittedTd = (updateData is Map)
              ? (updateData['teaching_details'] as List?)
              : null;
          if (submittedPicture != null && submittedPicture.isNotEmpty) {
            json['profile_picture'] = submittedPicture;
            json['profile_image'] = submittedPicture;
            json['image'] = submittedPicture;
          }
          if (submittedFront != null && submittedFront.isNotEmpty) {
            json['frontid'] = submittedFront;
            json['front_id'] = submittedFront;
          }
          if (submittedBack != null && submittedBack.isNotEmpty) {
            json['frontback'] = submittedBack;
            json['backid'] = submittedBack;
            json['back_id'] = submittedBack;
          }
          if (submittedIdType != null && submittedIdType.isNotEmpty) {
            json['idtype'] = submittedIdType;
            json['idType'] = submittedIdType;
          }

          final List<dynamic> mergedTdList = [];
          final Set<String> seenCombos = {};
          void addTdItem(dynamic item) {
            if (item == null) return;
            int? bId, cId, sId;
            if (item is TeachingDetails) {
              bId = item.boardId;
              cId = item.classId;
              sId = item.subjectId;
            } else if (item is Map) {
              bId = item['board_id'] is int ? item['board_id'] : int.tryParse(item['board_id']?.toString() ?? '');
              cId = item['class_id'] is int ? item['class_id'] : int.tryParse(item['class_id']?.toString() ?? '');
              sId = item['subject_id'] is int ? item['subject_id'] : int.tryParse(item['subject_id']?.toString() ?? '');
            }
            final key = '$bId-$cId-$sId';
            if (!seenCombos.contains(key)) {
              seenCombos.add(key);
              mergedTdList.add(item is TeachingDetails ? item.toJson() : item);
            }
          }

          if (submittedTd != null && submittedTd.isNotEmpty) {
            json['teaching_details'] = submittedTd;
          } else {
            if (json['teaching_details'] is List) {
              for (final item in json['teaching_details']) {
                addTdItem(item);
              }
            }
            final cachedTd = await StorageService.getTeachingDetails();
            if (cachedTd != null) {
              for (final item in cachedTd) {
                addTdItem(item);
              }
            }
            if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
              for (final item in tutorprofileData.value!.teachingDetails) {
                addTdItem(item);
              }
            }
            if (mergedTdList.isNotEmpty) {
              json['teaching_details'] = mergedTdList;
            }
          }

          tutorprofileData.value = TutorProfileData.fromJson(json);
          if (tutorprofileData.value != null && tutorprofileData.value!.teachingDetails.isNotEmpty) {
            await StorageService.saveTeachingDetails(
                tutorprofileData.value!.teachingDetails.map((e) => e.toJson()).toList());
          }
        }
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return true;
      } else {
          Get.snackbar(
          'Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false; // 👈 no return here
    }
  }

  Future<bool> updateProfileForStudent(
      StudentProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForStudent(updateData);
      if (!response.success) return _failed(response.message);
      // Student is directly verified - always navigate to dashboard!
      await StorageService.saveIsProfileStatus(2);
      await fetchProfileForStudent();
      Get.offAll(() => StudentDashboardScreen());
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStudentProfile(dynamic data) async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.updateStudentProfile(data);
      if (!response.success) return _failed(response.message);

      {
        if (data is Map) {
          final map = data;
          final String? newName =
              (map['student_name'] ?? map['name'] ?? map['full_name'])?.toString();
          if (newName != null &&
              newName.trim().isNotEmpty &&
              newName.trim().toLowerCase() != 'user' &&
              newName.trim().toLowerCase() != 'student') {
            await StorageService.saveUserName(newName.trim());
          }

          if (studentprofileData.value != null) {
            final String? newMobile = (map['mobile'] ?? map['phone'])?.toString();
            final String? newPic = map['profile_picture']?.toString();
            final String? newLoc = map['location']?.toString();
            final int? newBoardId = int.tryParse(map['board_id']?.toString() ?? '');
            final int? newCourseId = int.tryParse((map['course_id'] ?? map['class_id'])?.toString() ?? '');
            final int? newPincode = int.tryParse(map['pincode']?.toString() ?? '');
            final String? newBoardName = map['board_name']?.toString();
            final String? newCourseName = (map['course_name'] ?? map['class_name'])?.toString();
            final String? newPrice = map['price']?.toString();

            final updated = studentprofileData.value!.copyWith(
              studentName: (newName != null && newName.isNotEmpty) ? newName : studentprofileData.value!.studentName,
              mobile: (newMobile != null && newMobile.isNotEmpty) ? newMobile : studentprofileData.value!.mobile,
              profile_picture: (newPic != null && newPic.isNotEmpty) ? newPic : studentprofileData.value!.profile_picture,
              location: newLoc ?? studentprofileData.value!.location,
              boardId: newBoardId ?? studentprofileData.value!.boardId,
              courseId: newCourseId ?? studentprofileData.value!.courseId,
              boardName: (newBoardName != null && newBoardName.isNotEmpty) ? newBoardName : studentprofileData.value!.boardName,
              courseName: (newCourseName != null && newCourseName.isNotEmpty) ? newCourseName : studentprofileData.value!.courseName,
              pincode: newPincode ?? studentprofileData.value!.pincode,
              price: newPrice ?? studentprofileData.value!.price,
            );
            studentprofileData.value = updated;
          }
        }
      }

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false; // ✅ no return here
    }
  }

  /// ✅ Update profile with given data
  Future<bool> updateProfileForAdmin(
      TutorProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForTutor(updateData);
      if (!response.success) return _failed(response.message);
      tutorprofileData.value = response.data;
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // in your ProfileUpdateController (or appropriate controller)
  // In ProfileUpdateController
  Future<bool> updateAdminProfile(Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final msg = await _profileUpdateService.updateAdminProfile(updateData);

      // If service returned null, treat as failure
      if (msg == null) {
        Get.snackbar(
          'Error',
          'No response from server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Optionally update local profile data by re-fetching
      await fetchProfileForAdmin();

      return true;
    } catch (e, st) {
      debugPrint("❌ Error in updateAdminProfile controller: $e\n$st");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAdminProfileVerify(Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateAdminProfileVerifiy(updateData);

      // Assuming response.success is a boolean on the returned model
      if (response.success != true) {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      // Success path
      tutorprofileData.value = response.data;
      debugPrint("✅ Profile updated successfully");
      Get.snackbar(
        'Success',
        response.message.isNotEmpty ? response.message : 'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on TimeoutException catch (te) {
      debugPrint("⏱ Timeout: $te");
      Get.snackbar('Timeout', 'Request timed out. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return false;
    } catch (e, st) {
      debugPrint("❌ Error in updateProfile: $e\n$st");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      // only cleanup here — do NOT return from finally
      isLoading.value = false;
    }
  }

  bool _failed(String message) {
    Get.snackbar(
      'Failed',
      message.isNotEmpty ? message : 'Could not update profile. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
    return false;
  }
}

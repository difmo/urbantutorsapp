import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetCache();
  });

  group('Teaching Mode Persistence & Serialization', () {
    test('StorageService persists and retrieves teaching mode', () async {
      expect(StorageService.cachedTeachingMode, isNull);

      await StorageService.saveTeachingMode('Offline');
      expect(StorageService.cachedTeachingMode, 'Offline');

      final loaded = await StorageService.getTeachingMode();
      expect(loaded, 'Offline');

      // Test cache reset and reloading from prefs
      StorageService.resetCache();
      expect(StorageService.cachedTeachingMode, isNull);
      final fromPrefs = await StorageService.getTeachingMode();
      expect(fromPrefs, 'Offline');
      expect(StorageService.cachedTeachingMode, 'Offline');
    });

    test('TutorProfileData.fromJson correctly parses mode from "mode"', () {
      final json = {
        'id': 10,
        'mode': 'Offline',
      };
      final data = TutorProfileData.fromJson(json);
      expect(data.mode, 'Offline');
    });

    test('TutorProfileData.fromJson parses mode from "teaching_mode"', () {
      final json = {
        'id': 11,
        'teaching_mode': 'Both',
      };
      final data = TutorProfileData.fromJson(json);
      expect(data.mode, 'Both');
    });

    test('TutorProfileData.fromJson parses mode from "teachingMode"', () {
      final json = {
        'id': 12,
        'teachingMode': 'Online',
      };
      final data = TutorProfileData.fromJson(json);
      expect(data.mode, 'Online');
    });

    test('TutorProfileData.fromJson parses mode from nested user/userData', () {
      final json = {
        'id': 13,
        'userData': {
          'teaching_mode': 'Offline',
        },
      };
      final data = TutorProfileData.fromJson(json);
      expect(data.mode, 'Offline');
    });

    test('TutorProfileData.toJson includes mode, teaching_mode, and teachingMode', () {
      final data = TutorProfileData(id: 14, mode: 'Offline');
      final json = data.toJson();
      expect(json['mode'], 'Offline');
      expect(json['teaching_mode'], 'Offline');
      expect(json['teachingMode'], 'Offline');
    });

    test('TutorProfileData parses and serializes frontId, backId, and idType with all aliases', () {
      final json = {
        'id': 20,
        'frontid': 'uploads/teachers/front.jpg',
        'frontback': 'uploads/teachers/back.jpg',
        'idtype': 'Aadhar',
      };
      final data = TutorProfileData.fromJson(json);
      expect(data.frontId, 'uploads/teachers/front.jpg');
      expect(data.frontBack, 'uploads/teachers/back.jpg');
      expect(data.idType, 'Aadhar');

      final out = data.toJson();
      expect(out['frontid'], 'uploads/teachers/front.jpg');
      expect(out['front_id'], 'uploads/teachers/front.jpg');
      expect(out['frontback'], 'uploads/teachers/back.jpg');
      expect(out['backid'], 'uploads/teachers/back.jpg');
      expect(out['back_id'], 'uploads/teachers/back.jpg');
      expect(out['idtype'], 'Aadhar');
      expect(out['idType'], 'Aadhar');
    });

    test('StorageService persists and retrieves id type', () async {
      expect(StorageService.cachedIdType, isNull);

      await StorageService.saveIdType('Aadhar');
      expect(StorageService.cachedIdType, 'Aadhar');

      final loaded = await StorageService.getIdType();
      expect(loaded, 'Aadhar');

      StorageService.resetCache();
      expect(StorageService.cachedIdType, isNull);
      final fromPrefs = await StorageService.getIdType();
      expect(fromPrefs, 'Aadhar');
      expect(StorageService.cachedIdType, 'Aadhar');
    });

    test('TutorProfileData.fromJson parses teacher name from all aliases and skips generic/empty', () {
      final json1 = {
        'id': 30,
        'teacher_name': 'Rohan Sharma',
      };
      expect(TutorProfileData.fromJson(json1).teacherName, 'Rohan Sharma');

      final json2 = {
        'id': 31,
        'teacher_name': '',
        'name': 'Pooja Verma',
      };
      expect(TutorProfileData.fromJson(json2).teacherName, 'Pooja Verma');

      final json3 = {
        'id': 32,
        'teacher_name': 'User',
        'user': {
          'full_name': 'Amit Kumar',
        },
      };
      expect(TutorProfileData.fromJson(json3).teacherName, 'Amit Kumar');
    });

    test('TutorProfileData.toJson exports all name aliases', () {
      final data = TutorProfileData(id: 40, teacherName: 'Vikram Singh');
      final json = data.toJson();
      expect(json['teacher_name'], 'Vikram Singh');
      expect(json['teacherName'], 'Vikram Singh');
      expect(json['name'], 'Vikram Singh');
      expect(json['full_name'], 'Vikram Singh');
      expect(json['fullName'], 'Vikram Singh');
      expect(json['user_name'], 'Vikram Singh');
      expect(json['userName'], 'Vikram Singh');
      expect(json['tutor_name'], 'Vikram Singh');
    });

    test('StorageService persists user name and ignores generic overrides', () async {
      await StorageService.saveUserName('Sunil Gupta');
      expect(StorageService.cachedUserName, 'Sunil Gupta');

      // Attempt to overwrite with generic name 'User'
      await StorageService.saveUserName('User');
      expect(StorageService.cachedUserName, 'Sunil Gupta');

      // Verify retrieval
      final retrieved = await StorageService.getUserName();
      expect(retrieved, 'Sunil Gupta');
    });
  });
}


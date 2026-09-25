import 'package:flutter_test/flutter_test.dart';
import 'package:urbantutorsapp/models/profile_modals/admin_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';

// Shapes captured from the live API (values replaced with test data).
void main() {
  test('new bureau without a submitted profile has status 0', () {
    final r = AdminProfileResponseModel.fromJson({
      'success': true,
      'data': {
        'id': 1,
        'name': 'Test',
        'email': '9000000000',
        'profile_status': 0,
        'user_id': 'B0000001',
        'positionShow': 5,
        'tutorburo': null,
      },
      'message': 'Tutor Buro Profile Not Found.',
    });
    expect(r.data?.tutorburoProfileStatus, 0);
  });

  test('submitted bureau profile reports tutorburo_profile_status', () {
    final r = AdminProfileResponseModel.fromJson({
      'success': true,
      'data': {
        'tutorburo_id': 1,
        'tutorburo_profile_id': 15,
        'tutorburo_profile_status': 1,
        'full_name': null,
        'tutorburo_name': 'Test',
        'total_coins': 0,
      },
      'message': 'Tutor Buro Profile data Fetched Successfully.',
    });
    expect(r.data?.tutorburoProfileStatus, 1);
  });

  test('verify-submission response parses as success', () {
    final r = TutorProfileResponse.fromJson({
      'success': true,
      'data': {
        'id': 15,
        'user_id': '1',
        'tutor_bureau_name': 'Test',
        'frontid': 'public/uploads/teachers/frontid_x.jpg',
        'idtype': null,
        'latitude': '26.85',
      },
      'message': 'Tutor Buro Verify Profile Updated Successfully.',
    });
    expect(r.success, isTrue);
  });
}

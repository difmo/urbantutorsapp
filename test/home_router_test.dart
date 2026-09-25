import 'package:flutter_test/flutter_test.dart';
import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/admin/admin_pending_screen.dart';
import 'package:urbantutorsapp/screens/admin/admin_profile_form.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/screens/student/student_profile_form.dart';
import 'package:urbantutorsapp/screens/tutor/student_peding_screen.dart';
import 'package:urbantutorsapp/screens/tutor/teacher_pending_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_form.dart';
import 'package:urbantutorsapp/shared/default_dashboard.dart';
import 'package:urbantutorsapp/utils/home_router.dart';

void main() {
  test('every role follows form → pending → dashboard', () {
    expect(homeScreenFor(Roles.student, 0), isA<StudentProfileFormScreen>());
    expect(homeScreenFor(Roles.student, 1), isA<StudentPendingScreen>());
    expect(homeScreenFor(Roles.student, 2), isA<StudentDashboardScreen>());

    expect(homeScreenFor(Roles.tutor, 0), isA<TutorProfileFormScreen>());
    expect(homeScreenFor(Roles.tutor, 1), isA<TeacherPendingScreen>());
    expect(homeScreenFor(Roles.tutor, 2), isA<TutorDashboard>());

    expect(homeScreenFor(Roles.tutorBureau, 0), isA<AdminProfileForm>());
    expect(homeScreenFor(Roles.tutorBureau, 1), isA<AdminPendingScreen>());
    expect(homeScreenFor(Roles.tutorBureau, 2), isA<AdminDashboard>());
  });

  test('unknown role or status falls back to the default screen', () {
    expect(homeScreenFor(99, 2), isA<DefaultDashboardScreen>());
    expect(homeScreenFor(null, null), isA<DefaultDashboardScreen>());
    expect(homeScreenFor(Roles.tutor, 7), isA<DefaultDashboardScreen>());
  });
}

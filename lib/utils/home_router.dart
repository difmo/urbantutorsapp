import 'package:flutter/widgets.dart';
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

/// Role ids used by the backend.
class Roles {
  static const tutor = 2;
  static const student = 3;
  static const tutorBureau = 5;
}

/// The screen a logged-in user lands on, for every role:
/// profile status 0 → profile form, 1 → pending verification, 2 → dashboard.
Widget homeScreenFor(int? roleId, int? profileStatus) {
  switch (roleId) {
    case Roles.student:
      return switch (profileStatus) {
        0 => StudentProfileFormScreen(),
        1 => const StudentPendingScreen(),
        2 => StudentDashboardScreen(),
        _ => const DefaultDashboardScreen(),
      };
    case Roles.tutor:
      return switch (profileStatus) {
        0 => TutorProfileFormScreen(),
        1 => const TeacherPendingScreen(),
        2 => TutorDashboard(),
        _ => const DefaultDashboardScreen(),
      };
    case Roles.tutorBureau:
      return switch (profileStatus) {
        0 => AdminProfileForm(),
        1 => const AdminPendingScreen(),
        2 => AdminDashboard(),
        _ => const DefaultDashboardScreen(),
      };
    default:
      return const DefaultDashboardScreen();
  }
}

import 'package:urbantutorsapp/utils/api_config.dart';

export 'package:urbantutorsapp/utils/api_config.dart';

class ApiConstants {
  static String get BASE_URL => ApiConfig.baseUrl;
  static String get SEND_OTP => ApiConfig.sendOtp;
  static String get GETCLASS_URL => ApiConfig.getClasses;
  static String get VERIFY_OTP => ApiConfig.verifyOtp;
  static String get GET_CHAPTER_DETAILS => ApiConfig.getChapterDetails;
  static String get GET_SUBJECT_URL => ApiConfig.getSubjects;
  static String get GET_CHAPTER_URL => ApiConfig.getChapter;
  static String get LEAD_CREATE_URL => ApiConfig.fullLeadCreateUrl;
  static String get LEAD_SERVICE_URL => ApiConfig.leadsView;
  static String get PROFILE_SERVICE => ApiConfig.userProfile;
  static String get PROFILE_UPDATE => ApiConfig.profileUpdate;
  static String get USER_PROFIEL_FETCH => ApiConfig.userProfile;
  static String get STUDENT_PROFILE_UPDATE => ApiConfig.studentProfileUpdate;
  static String get MASTERDATE => ApiConfig.masterData;

  static String get LEADS_VIEW_URL => ApiConfig.fullLeadsViewUrl;
  static String get GRAB_LEAD => ApiConfig.fullGrabLeadUrl;
  static String get GRABLEAD_VIEW => ApiConfig.fullGrabLeadViewUrl;
  static String get GRABLEAD_DECLINE_VIEW => ApiConfig.fullGrabLeadDeclineViewUrl;
  static String get GRABLEAD_DECLINE => ApiConfig.fullGrabLeadDeclineUrl;
}

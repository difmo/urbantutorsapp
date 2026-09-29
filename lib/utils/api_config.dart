import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

/// Central API Configuration
class ApiConfig {
  static String get baseUrl {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['BASE_URL'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'https://urbantutors.pro/api/';
  }

  static String get serverHost {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['SERVER_HOST'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'https://urbantutors.pro';
  }

  /// Auth token getter from storage
  static Future<String?> get token => StorageService.getToken();

  /// Centralized Auth & API headers
  static Future<Map<String, String>> getHeaders({
    String? token,
    bool isJson = true,
  }) async {
    final authToken = token ?? await StorageService.getToken();
    return {
      'Accept': 'application/json',
      if (isJson) 'Content-Type': 'application/json',
      if (authToken != null && authToken.trim().isNotEmpty)
        'Authorization': 'Bearer ${authToken.trim()}',
    };
  }

  static String get razorpayKeyId {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['RAZORPAY_KEY_ID'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'rzp_test_G8C4fq7TzDzwgm';
  }

  static String get razorpayKeySecret {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['RAZORPAY_KEY_SECRET'];
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return 'jx32K2TTW84b1Gj53IWAfFVf';
  }

  // ==========================================
  // Auth Endpoints
  // ==========================================
  static const String sendOtp = '/send_otp';
  static const String verifyOtp = '/verify_otp';

  // ==========================================
  // Master Data & Location Endpoints
  // ==========================================
  static const String masterData = '/master_data';
  static const String getLocation = '/getlocation';
  static const String searchLocation = '/search_location';
  static String get fullGetLocationUrl => '$baseUrl${getLocation.replaceFirst(RegExp(r'^/'), '')}';

  // ==========================================
  // Leads Endpoints
  // ==========================================
  static const String leadsView = '/leads_vew';
  static const String leadCreateUpdate = '/leadscreateupdate';
  static const String grabLead = '/grablead';
  static const String grabLeadView = '/grablead_veiw';
  static const String grabLeadDecline = '/grablead_decllin';
  static const String grabLeadDeclineView = '/grablead_decllin_veiw';
  static const String declinedLeads = '/leads_declined_view';
  static const String contactedLeads = '/contacted_leads_view';
  static const String unlockLead = '/unlock_lead';

  // Full URLs for Leads
  static String get fullLeadsViewUrl => '$baseUrl${leadsView.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullLeadCreateUrl => '$baseUrl${leadCreateUpdate.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGrabLeadUrl => '$baseUrl${grabLead.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGrabLeadViewUrl => '$baseUrl${grabLeadView.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGrabLeadDeclineUrl => '$baseUrl${grabLeadDecline.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGrabLeadDeclineViewUrl => '$baseUrl${grabLeadDeclineView.replaceFirst(RegExp(r'^/'), '')}';

  // ==========================================
  // User Profile Endpoints
  // ==========================================
  static const String userProfile = '/user_profile';
  static const String profileUpdate = '/profileupdate';
  static const String studentProfileUpdate = '/student_profile_update';
  static const String tutorburoProfileUpdate = '/tutorburo_profile_update';
  static const String tutorburoStatusUpdate = '/tutorburo_status_update';
  static const String teacherProfileUpdate = '/teacher_profile_update';
  static const String tutorburoProfileVerify = '/tutorburo_profile_verify';

  // ==========================================
  // Courses & Notes Endpoints
  // ==========================================
  static const String getClasses = '/leadclassget';
  static const String getSubjects = '/getsubjects';
  static const String getChapter = '/getchapter';
  static const String getChapterDetails = '/getchapter_details';
  static const String getClassesNotes = '/getclasses';
  static const String getPayCourse = '/getpaycourse';
  static const String purchaseCourse = '/purchagecourse';
  static const String myCourse = '/mycourse';
  static String viewPdf(dynamic courseId) => '/viewpdf/$courseId';

  // Full URLs for Notes & Classes
  static String get fullGetClassesNotesUrl => '$baseUrl${getClassesNotes.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGetSubjectsUrl => '$baseUrl${getSubjects.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGetChapterUrl => '$baseUrl${getChapter.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullGetChapterDetailsUrl => '$baseUrl${getChapterDetails.replaceFirst(RegExp(r'^/'), '')}';

  // Lead Meta Endpoints
  static const String leadGetSubjects = '/leadgetsubjects';
  static const String leadGetChapters = '/leadgetchapters';
  static const String leadGetChapterDetails = '/getchapterdetails';

  static String get fullLeadGetSubjectsUrl => '$baseUrl${leadGetSubjects.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullLeadGetChaptersUrl => '$baseUrl${leadGetChapters.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullLeadGetChapterDetailsUrl => '$baseUrl${leadGetChapterDetails.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullLeadClassGetUrl => '$baseUrl${getClasses.replaceFirst(RegExp(r'^/'), '')}';

  // ==========================================
  // Coins & Transactions Endpoints
  // ==========================================
  static const String getCoins = '/get_coins';
  static const String myCoins = '/my_coins';
  static const String purchaseCoins = '/purchagecoins';
  static const String quinceCreateOrder = '/create_quince_order';
  static const String registerOrder = '/create_order';
  static const String verifyPayment = '/verify_payment';
  static const String transactionView = '/transaction_view';

  static String get fullGetCoinsUrl => '$baseUrl${getCoins.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullMyCoinsUrl => '$baseUrl${myCoins.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullPurchaseCoinsUrl => '$baseUrl${purchaseCoins.replaceFirst(RegExp(r'^/'), '')}';
  static String get fullRegisterOrderUrl => '$baseUrl${registerOrder.replaceFirst(RegExp(r'^/'), '')}';

  // ==========================================
  // Pro Membership Endpoints
  // ==========================================
  static const String getProPlans = '/get_pro_plans';
  static const String buyProMembership = '/buy_pro_membership';
  static const String purchaseProMembership = '/purchased_pro_membership';
  static const String getProMembershipView = '/get_pro_membership_view';
  static const String getProMembership = '/get_pro_membership';
  static const String getNearbyStudent = '/getNearbystudent';

  // ==========================================
  // Notifications Endpoints
  // ==========================================
  static String notificationsReadView(dynamic userId) => '/notifications_read_view/$userId';
  static String notificationsCount(dynamic userId) => '/notifications_count/$userId';
  static const String notificationsRead = '/notifications_read';

  // ==========================================
  // Chat & Feedback Endpoints
  // ==========================================
  static const String chatSend = '/send_chat';
  static const String chatView = '/chat_view';
  static const String chatUsers = '/chat_users_list';
  static const String submitFeedback = '/feedback_create';
  static const String feedbackView = '/feedback_view';
}

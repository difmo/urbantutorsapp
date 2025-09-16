import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _roleIdKey = 'role_id';
  static const String _profileIdKey = 'is_profile_done';
  static const String _saveUserID = 'user_id';
    static const String _name = 'name';
        static const String _phone_number = 'phone_number';
                static const String _lead_status = 'lead_status';

  /// Save token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveUserID, userId.toString());
  }
   static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_saveUserID);
  }


   static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_name, name);
  }
   static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_name);
  }


   static Future<void> saveUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phone_number, phone);
  }
   static Future<String?> getUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phone_number);
  }

     static Future<void> saveUserLeadStatus(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lead_status, phone);
  }
   static Future<String?> getUserLeadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lead_status);
  }

  /// Save user role to local storage
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<void> saveIsProfileStatus(int isProfileDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_profileIdKey, isProfileDone);
  }

  static Future<void> saveRoleId(int roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_roleIdKey, roleId);
  }

  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleIdKey);
  }

 

  static Future<int?> getIsProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileIdKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearTokenAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

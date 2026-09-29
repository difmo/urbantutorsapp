import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Robust local storage service with in-memory caching and safe fallbacks.
/// Protects against Android Pigeon PlatformException(channel-error) during
/// hot reload, restarts, or platform channel drops.
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _altTokenKey = 'token';
  static const String _roleKey = 'user_role';
  static const String _roleIdKey = 'role_id';
  static const String _profileIdKey = 'is_profile_done';
  static const String _saveUserID = 'user_id';
  static const String _name = 'name';
  static const String _phoneNumber = 'phone_number';
  static const String _leadStatus = 'lead_status';

  // In-memory cache ensures zero crashes if platform channel fails
  static String? _cachedToken;
  static String? _cachedUserId;
  static String? _cachedUserName;
  static String? _cachedUserPhone;
  static String? _cachedLeadStatus;
  static String? _cachedRole;
  static int? _cachedRoleId;
  static int? _cachedProfileStatus;

  @visibleForTesting
  static void resetCache() {
    _cachedToken = null;
    _cachedUserId = null;
    _cachedUserName = null;
    _cachedUserPhone = null;
    _cachedLeadStatus = null;
    _cachedRole = null;
    _cachedRoleId = null;
    _cachedProfileStatus = null;
  }

  static Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      print('\x1B[93m[StorageService WARNING] SharedPreferences channel error: $e\x1B[0m');
      return null;
    }
  }

  /// Save all user session data in a single batch
  static Future<void> saveUserSession({
    required String token,
    required int roleId,
    required int profileStatus,
    required int userId,
    required String userName,
    required String userPhone,
  }) async {
    _cachedToken = token;
    _cachedRoleId = roleId;
    _cachedProfileStatus = profileStatus;
    _cachedUserId = userId.toString();
    _cachedUserName = userName;
    _cachedUserPhone = userPhone;

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_tokenKey, token),
          prefs.setString(_altTokenKey, token),
          prefs.setInt(_roleIdKey, roleId),
          prefs.setInt(_profileIdKey, profileStatus),
          prefs.setString(_saveUserID, userId.toString()),
          prefs.setString(_name, userName),
          prefs.setString(_phoneNumber, userPhone),
        ]);
      }
    } catch (e) {
      print('\x1B[93m[StorageService] saveUserSession error: $e\x1B[0m');
    }
  }

  /// Save token to local storage
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_tokenKey, token),
          prefs.setString(_altTokenKey, token),
        ]);
      }
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.trim().isNotEmpty) {
      return _cachedToken;
    }
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return _cachedToken;

      // 1. Try standard auth_token key
      var val = prefs.getString(_tokenKey);
      if (val != null && val.trim().isNotEmpty) {
        _cachedToken = val.trim();
        return _cachedToken;
      }

      // 2. Try alternate token key
      val = prefs.getString(_altTokenKey);
      if (val != null && val.trim().isNotEmpty) {
        _cachedToken = val.trim();
        await prefs.setString(_tokenKey, _cachedToken!);
        return _cachedToken;
      }

      // 3. Try parsing userData json blob
      final userDataStr = prefs.getString('userData');
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(userDataStr);
          if (decoded is Map) {
            final t = decoded['token'] ?? decoded['data']?['token'];
            if (t != null && t.toString().trim().isNotEmpty) {
              _cachedToken = t.toString().trim();
              await prefs.setString(_tokenKey, _cachedToken!);
              return _cachedToken;
            }
          }
        } catch (_) {}
      }

      return _cachedToken;
    } catch (_) {
      return _cachedToken;
    }
  }

  static Future<void> saveUserId(int userId) async {
    _cachedUserId = userId.toString();
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_saveUserID, userId.toString());
    } catch (_) {}
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_saveUserID);
      if (val != null && val.isNotEmpty) {
        _cachedUserId = val;
        return val;
      }
      return _cachedUserId ?? '1';
    } catch (_) {
      return _cachedUserId ?? '1';
    }
  }

  static Future<void> saveUserName(String name) async {
    _cachedUserName = name;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_name, name);
    } catch (_) {}
  }

  static Future<String?> getUserName() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_name);
      if (val != null && val.isNotEmpty) {
        _cachedUserName = val;
        return val;
      }
      return _cachedUserName;
    } catch (_) {
      return _cachedUserName;
    }
  }

  static Future<void> saveUserPhone(String phone) async {
    _cachedUserPhone = phone;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_phoneNumber, phone);
    } catch (_) {}
  }

  static Future<String?> getUserPhoneNumber() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_phoneNumber);
      if (val != null && val.isNotEmpty) {
        _cachedUserPhone = val;
        return val;
      }
      return _cachedUserPhone;
    } catch (_) {
      return _cachedUserPhone;
    }
  }

  static Future<void> saveUserLeadStatus(String status) async {
    _cachedLeadStatus = status;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_leadStatus, status);
    } catch (_) {}
  }

  static Future<String?> getUserLeadStatus() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_leadStatus);
      if (val != null) {
        _cachedLeadStatus = val;
        return val;
      }
      return _cachedLeadStatus;
    } catch (_) {
      return _cachedLeadStatus;
    }
  }

  static Future<void> saveRole(String role) async {
    _cachedRole = role;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_roleKey, role);
    } catch (_) {}
  }

  static Future<String?> getRole() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.getString(_roleKey);
      if (val != null) {
        _cachedRole = val;
        return val;
      }
      return _cachedRole;
    } catch (_) {
      return _cachedRole;
    }
  }

  static Future<void> saveIsProfileStatus(int isProfileDone) async {
    _cachedProfileStatus = isProfileDone;
    try {
      final prefs = await _getPrefs();
      await prefs?.setInt(_profileIdKey, isProfileDone);
    } catch (_) {}
  }

  static Future<int?> getIsProfileStatus() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.get(_profileIdKey);
      if (val is int) {
        _cachedProfileStatus = val;
        return val;
      }
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) {
          _cachedProfileStatus = parsed;
          return parsed;
        }
      }
      return _cachedProfileStatus;
    } catch (_) {
      return _cachedProfileStatus;
    }
  }

  static Future<void> saveRoleId(int roleId) async {
    _cachedRoleId = roleId;
    try {
      final prefs = await _getPrefs();
      await prefs?.setInt(_roleIdKey, roleId);
    } catch (_) {}
  }

  static Future<int?> getRoleId() async {
    try {
      final prefs = await _getPrefs();
      final val = prefs?.get(_roleIdKey);
      if (val is int) {
        _cachedRoleId = val;
        return val;
      }
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) {
          _cachedRoleId = parsed;
          return parsed;
        }
      }
      return _cachedRoleId;
    } catch (_) {
      return _cachedRoleId;
    }
  }

  static Future<void> clearTokenAndRole() async {
    _cachedToken = null;
    _cachedRole = null;
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_tokenKey);
      await prefs?.remove(_altTokenKey);
      await prefs?.remove(_roleKey);
    } catch (_) {}
  }

  static Future<void> clear() async {
    resetCache();
    try {
      final prefs = await _getPrefs();
      await prefs?.clear();
    } catch (_) {}
  }
}

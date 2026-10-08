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
  static const String _teachingModeKey = 'teaching_mode';
  static const String _idTypeKey = 'id_type';

  // In-memory cache ensures zero crashes if platform channel fails
  static String? _cachedToken;
  static String? _cachedUserId;
  static String? _cachedUserName;
  static String? _cachedUserPhone;
  static String? _cachedLeadStatus;
  static String? _cachedRole;
  static int? _cachedRoleId;
  static int? _cachedProfileStatus;
  static String? _cachedTeachingMode;
  static String? _cachedIdType;
  static String? _cachedTeachingDetailsJson;

  /// Synchronous in-memory access to the current cached user name
  static String? get cachedUserName => _cachedUserName;

  /// Synchronous in-memory access to the current cached teaching mode
  static String? get cachedTeachingMode => _cachedTeachingMode;

  /// Synchronous in-memory access to the current cached id type
  static String? get cachedIdType => _cachedIdType;

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
    _cachedTeachingMode = null;
    _cachedIdType = null;
    _cachedTeachingDetailsJson = null;
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
    // Preserve valid existing name if incoming userName is generic ('User', 'Tutor', empty)
    final incoming = userName.trim();
    if (incoming.isEmpty ||
        incoming.toLowerCase() == 'user' ||
        incoming.toLowerCase() == 'urban user' ||
        incoming.toLowerCase() == 'tutor') {
      final existing = await getUserName();
      if (existing != null && existing.trim().isNotEmpty) {
        _cachedUserName = existing.trim();
      } else {
        _cachedUserName = incoming.isNotEmpty ? incoming : 'User';
      }
    } else {
      _cachedUserName = incoming;
    }

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_tokenKey, token),
          prefs.setString(_altTokenKey, token),
          prefs.setInt(_roleIdKey, roleId),
          prefs.setInt(_profileIdKey, profileStatus),
          prefs.setString(_saveUserID, userId.toString()),
          prefs.setString(_name, _cachedUserName!),
          prefs.setString('student_name', _cachedUserName!),
          prefs.setString('teacher_name', _cachedUserName!),
          prefs.setString('reg_name', _cachedUserName!),
          prefs.setString('user_name', _cachedUserName!),
          prefs.setString('full_name', _cachedUserName!),
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
    final clean = name.trim();
    if (clean.isEmpty ||
        clean.toLowerCase() == 'user' ||
        clean.toLowerCase() == 'urban user' ||
        clean.toLowerCase() == 'tutor') {
      // Do NOT overwrite an existing valid user name with a generic fallback!
      return;
    }
    _cachedUserName = clean;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_name, clean),
          prefs.setString('teacher_name', clean),
          prefs.setString('student_name', clean),
          prefs.setString('reg_name', clean),
          prefs.setString('user_name', clean),
          prefs.setString('full_name', clean),
        ]);
      }
    } catch (_) {}
  }

  static Future<String?> getUserName() async {
    try {
      if (_cachedUserName != null &&
          _cachedUserName!.trim().isNotEmpty &&
          _cachedUserName!.trim().toLowerCase() != 'user' &&
          _cachedUserName!.trim().toLowerCase() != 'urban user' &&
          _cachedUserName!.trim().toLowerCase() != 'tutor') {
        return _cachedUserName!.trim();
      }

      final prefs = await _getPrefs();
      if (prefs == null) return _cachedUserName;

      // 1. Check all standard keys in priority order
      final keysToCheck = [
        'student_name',
        'teacher_name',
        _name, // 'name'
        'reg_name',
        'user_name',
        'full_name',
      ];

      for (final k in keysToCheck) {
        final val = prefs.getString(k);
        if (val != null &&
            val.trim().isNotEmpty &&
            val.trim().toLowerCase() != 'user' &&
            val.trim().toLowerCase() != 'urban user' &&
            val.trim().toLowerCase() != 'student' &&
            val.trim().toLowerCase() != 'tutor') {
          _cachedUserName = val.trim();
          await prefs.setString(_name, _cachedUserName!);
          await prefs.setString('student_name', _cachedUserName!);
          return _cachedUserName;
        }
      }

      // 2. Try parsing name from stored userData json blob
      final userDataStr = prefs.getString('userData');
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(userDataStr);
          if (decoded is Map) {
            final u = decoded['userData'] ??
                decoded['data']?['userData'] ??
                decoded['data'] ??
                decoded['user'] ??
                decoded;
            if (u is Map) {
              final candidates = [
                u['student_name'],
                u['teacher_name'],
                u['name'],
                u['full_name'],
                u['user_name'],
              ];
              for (final c in candidates) {
                if (c != null) {
                  final s = c.toString().trim();
                  if (s.isNotEmpty &&
                      s.toLowerCase() != 'user' &&
                      s.toLowerCase() != 'urban user' &&
                      s.toLowerCase() != 'student' &&
                      s.toLowerCase() != 'tutor') {
                    _cachedUserName = s;
                    await prefs.setString(_name, s);
                    await prefs.setString('student_name', s);
                    return _cachedUserName;
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      // 3. If in-memory cache is non-generic, return it
      if (_cachedUserName != null &&
          _cachedUserName!.trim().isNotEmpty &&
          _cachedUserName!.trim().toLowerCase() != 'user' &&
          _cachedUserName!.trim().toLowerCase() != 'student') {
        return _cachedUserName;
      }

      // 4. Fallback to whatever is stored if no custom name matched
      final fallback = prefs.getString('student_name') ??
          prefs.getString(_name) ??
          prefs.getString('user_name') ??
          _cachedUserName;
      if (fallback != null &&
          fallback.trim().isNotEmpty &&
          fallback.trim().toLowerCase() != 'user' &&
          fallback.trim().toLowerCase() != 'student') {
        _cachedUserName = fallback.trim();
        return _cachedUserName;
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

  static Future<void> saveTeachingMode(String mode) async {
    final clean = mode.trim();
    if (clean.isEmpty) return;
    _cachedTeachingMode = clean;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_teachingModeKey, clean),
          prefs.setString('mode', clean),
        ]);
      }
    } catch (e) {
      print('\x1B[93m[StorageService] saveTeachingMode error: $e\x1B[0m');
    }
  }

  static Future<String?> getTeachingMode() async {
    if (_cachedTeachingMode != null && _cachedTeachingMode!.trim().isNotEmpty) {
      return _cachedTeachingMode;
    }
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        final val = prefs.getString(_teachingModeKey) ?? prefs.getString('mode');
        if (val != null && val.trim().isNotEmpty) {
          _cachedTeachingMode = val.trim();
          return _cachedTeachingMode;
        }

        // Try extracting from stored userData JSON blob if present
        final userDataStr = prefs.getString('userData');
        if (userDataStr != null && userDataStr.isNotEmpty) {
          try {
            final decoded = jsonDecode(userDataStr);
            if (decoded is Map) {
              final u = decoded['userData'] ??
                  decoded['data']?['userData'] ??
                  decoded['data'] ??
                  decoded['user'] ??
                  decoded;
              if (u is Map) {
                final modeCandidate =
                    (u['mode'] ?? u['teaching_mode'] ?? u['teachingMode'])
                        ?.toString()
                        .trim();
                if (modeCandidate != null && modeCandidate.isNotEmpty) {
                  _cachedTeachingMode = modeCandidate;
                  await prefs.setString(_teachingModeKey, modeCandidate);
                  return _cachedTeachingMode;
                }
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    return _cachedTeachingMode;
  }

  static Future<void> saveIdType(String idType) async {
    final clean = idType.trim();
    if (clean.isEmpty) return;
    _cachedIdType = clean;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await Future.wait([
          prefs.setString(_idTypeKey, clean),
          prefs.setString('idtype', clean),
          prefs.setString('idType', clean),
        ]);
      }
    } catch (e) {
      print('\x1B[93m[StorageService] saveIdType error: $e\x1B[0m');
    }
  }

  static Future<String?> getIdType() async {
    if (_cachedIdType != null && _cachedIdType!.trim().isNotEmpty) {
      return _cachedIdType;
    }
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        final val = prefs.getString(_idTypeKey) ??
            prefs.getString('idtype') ??
            prefs.getString('idType');
        if (val != null && val.trim().isNotEmpty) {
          _cachedIdType = val.trim();
          return _cachedIdType;
        }

        final userDataStr = prefs.getString('userData');
        if (userDataStr != null && userDataStr.isNotEmpty) {
          try {
            final decoded = jsonDecode(userDataStr);
            if (decoded is Map) {
              final u = decoded['userData'] ??
                  decoded['data']?['userData'] ??
                  decoded['data'] ??
                  decoded['user'] ??
                  decoded;
              if (u is Map) {
                final idCandidate = (u['idtype'] ?? u['idType'] ?? u['id_type'])
                    ?.toString()
                    .trim();
                if (idCandidate != null && idCandidate.isNotEmpty) {
                  _cachedIdType = idCandidate;
                  return _cachedIdType;
                }
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    return _cachedIdType;
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

  static const String _cachedTeachingDetailsKey = 'cached_teaching_details';
  static const String _cachedKnownMetaNamesKey = 'cached_known_meta_names';

  static Future<void> saveTeachingDetails(List<dynamic> details) async {
    try {
      final jsonStr = jsonEncode(details);
      _cachedTeachingDetailsJson = jsonStr;
      final prefs = await _getPrefs();
      await prefs?.setString(_cachedTeachingDetailsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>?> getTeachingDetails() async {
    try {
      if (_cachedTeachingDetailsJson != null && _cachedTeachingDetailsJson!.isNotEmpty) {
        final decoded = jsonDecode(_cachedTeachingDetailsJson!);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      final prefs = await _getPrefs();
      final str = prefs?.getString(_cachedTeachingDetailsKey);
      if (str != null && str.isNotEmpty) {
        _cachedTeachingDetailsJson = str;
        final decoded = jsonDecode(str);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> saveKnownMetaNames({
    Map<int, String>? boards,
    Map<int, String>? classes,
    Map<int, String>? subjects,
  }) async {
    try {
      final prefs = await _getPrefs();
      final existingStr = prefs?.getString(_cachedKnownMetaNamesKey);
      Map<String, dynamic> data = {};
      if (existingStr != null && existingStr.isNotEmpty) {
        try {
          data = Map<String, dynamic>.from(jsonDecode(existingStr) as Map);
        } catch (_) {}
      }
      if (boards != null) {
        data['boards'] = {...(data['boards'] is Map ? data['boards'] as Map : {}), ...boards.map((k, v) => MapEntry(k.toString(), v))};
      }
      if (classes != null) {
        data['classes'] = {...(data['classes'] is Map ? data['classes'] as Map : {}), ...classes.map((k, v) => MapEntry(k.toString(), v))};
      }
      if (subjects != null) {
        data['subjects'] = {...(data['subjects'] is Map ? data['subjects'] as Map : {}), ...subjects.map((k, v) => MapEntry(k.toString(), v))};
      }
      await prefs?.setString(_cachedKnownMetaNamesKey, jsonEncode(data));
    } catch (_) {}
  }

  static Future<Map<String, Map<int, String>>> getKnownMetaNames() async {
    final Map<String, Map<int, String>> res = {'boards': {}, 'classes': {}, 'subjects': {}};
    try {
      final prefs = await _getPrefs();
      final str = prefs?.getString(_cachedKnownMetaNamesKey);
      if (str != null && str.isNotEmpty) {
        final decoded = jsonDecode(str);
        if (decoded is Map) {
          for (final key in ['boards', 'classes', 'subjects']) {
            if (decoded[key] is Map) {
              final map = decoded[key] as Map;
              map.forEach((k, v) {
                final id = int.tryParse(k.toString());
                if (id != null && v != null) {
                  res[key]![id] = v.toString();
                }
              });
            }
          }
        }
      }
    } catch (_) {}
    return res;
  }

  static Future<void> clearTokenAndRole() async {
    _cachedToken = null;
    _cachedRole = null;
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_tokenKey);
      await prefs?.remove(_altTokenKey);
      await prefs?.remove(_roleKey);
      await prefs?.remove(_cachedTeachingDetailsKey);
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

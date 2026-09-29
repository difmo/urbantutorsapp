class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    LoginData? loginData;
    String message = (json['message'] ?? 'Unknown error').toString();

    try {
      if (json['data'] != null && json['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(json['data']);
        if (dataMap.containsKey('message') && dataMap['message'] != null) {
          message = dataMap['message'].toString();
        }
        if (dataMap.containsKey('token') || dataMap.containsKey('user_data')) {
          loginData = LoginData.fromJson(dataMap);
        }
      } else if (json['token'] != null) {
        loginData = LoginData.fromJson(json);
      }
    } catch (_) {
      loginData = null;
    }

    return LoginResponse(
      success: json['success'] == true,
      message: message,
      data: loginData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'LoginResponse(success: $success, message: $message, data: $data)';
  }
}

class LoginData {
  final String? token;
  final String? fairbasetoken;
  final UserData? userData;

  LoginData({
    this.token,
    this.fairbasetoken,
    this.userData,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token']?.toString(),
      fairbasetoken: (json['fairbasetoken'] ?? json['firebase_token'])?.toString(),
      userData: json['user_data'] != null && json['user_data'] is Map
          ? UserData.fromJson(Map<String, dynamic>.from(json['user_data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'fairbasetoken': fairbasetoken,
      'user_data': userData?.toJson(),
    };
  }

  @override
  String toString() {
    return 'LoginData(token: $token, fairbasetoken: $fairbasetoken, userData: $userData)';
  }
}

class UserData {
  final int id;
  final int? profileStatus; 
  final String name;
  final String mobile;
  final String createdAt;
  final String updatedAt;
  final List<Role> roles;

  UserData({
    required this.id,
    required this.profileStatus,
    required this.name,
    required this.mobile,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final List<Role> rolesList = (rolesRaw is List)
        ? rolesRaw
            .whereType<Map>()
            .map((r) => Role.fromJson(Map<String, dynamic>.from(r)))
            .toList()
        : [];

    return UserData(
      id: int.tryParse('${json['id']}') ?? 0,
      profileStatus: json['profile_status'] != null
          ? int.tryParse('${json['profile_status']}')
          : null,
      name: (json['name'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_status': profileStatus,
      'name': name,
      'mobile': mobile,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'UserData(id: $id, name: $name, profileStatus: $profileStatus, mobile: $mobile, createdAt: $createdAt, updatedAt: $updatedAt, roles: $roles)';
  }
}

class Role {
  final int roleId;
  final String roleName;

  Role({
    required this.roleId,
    required this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: int.tryParse('${json['role_id']}') ?? 0,
      roleName: (json['role_name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
    };
  }

  @override
  String toString() {
    return 'Role(roleId: $roleId, roleName: $roleName)';
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: LoginData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
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
      token: json['token'] as String?,
      fairbasetoken: json['fairbasetoken'] as String?,
      userData: json['user_data'] != null ? UserData.fromJson(json['user_data']) : null,
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
    var rolesList = (json['roles'] as List)
        .map((roleJson) => Role.fromJson(roleJson))
        .toList();

    return UserData(
      id: json['id'],
      profileStatus: json['profile_status'],
      name: json['name'],
      mobile: json['mobile'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      roleId: json['role_id'],
      roleName: json['role_name'],
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

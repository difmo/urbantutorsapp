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
}

class LoginData {
  final String token;
  final String fairbasetoken;
  final UserData userData;

  LoginData({
    required this.token,
    required this.fairbasetoken,
    required this.userData,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      fairbasetoken: json['fairbasetoken'],
      userData: UserData.fromJson(json['user_data']),
    );
  }
}

class UserData {
  final int id;
  final String name;
  final String mobile;
  final String createdAt;
  final String updatedAt;
  final List<Role> roles;

  UserData({
    required this.id,
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
      name: json['name'],
      mobile: json['mobile'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      roles: rolesList,
    );
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
}

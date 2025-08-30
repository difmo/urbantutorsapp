class MasterDataResponse {
  final bool success;
  final MasterData? data;
  final String message;

  MasterDataResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory MasterDataResponse.fromJson(Map<String, dynamic> json) {
    return MasterDataResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? MasterData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data?.toJson(),
      "message": message,
    };
  }
}

class MasterData {
  final String? privacyPolicy;
  final List<BoardLead>? boardLead;
  final List<BoardLead>? boardNotePyq;
  final List<MostExperienceSubject>? mostExperienceSubject;
  final List<SubscriptionCategory>? subscriptionCategory;
  final List<Role>? roles;

  MasterData({
    this.privacyPolicy,
    this.boardLead,
    this.boardNotePyq,
    this.mostExperienceSubject,
    this.subscriptionCategory,
    this.roles,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    return MasterData(
      privacyPolicy: json['privacy_Policy'],
      boardLead: (json['board_Lead'] as List<dynamic>?)
          ?.map((e) => BoardLead.fromJson(e))
          .toList(),
      boardNotePyq: (json['board_NotePyq'] as List<dynamic>?)
          ?.map((e) => BoardLead.fromJson(e))
          .toList(),
      mostExperienceSubject: (json['mostexperiensubject'] as List<dynamic>?)
          ?.map((e) => MostExperienceSubject.fromJson(e))
          .toList(),
      subscriptionCategory: (json['subscription_category'] as List<dynamic>?)
          ?.map((e) => SubscriptionCategory.fromJson(e))
          .toList(),
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "privacy_Policy": privacyPolicy,
      "board_Lead": boardLead?.map((e) => e.toJson()).toList(),
      "board_NotePyq": boardNotePyq?.map((e) => e.toJson()).toList(),
      "mostexperiensubject":
          mostExperienceSubject?.map((e) => e.toJson()).toList(),
      "subscription_category":
          subscriptionCategory?.map((e) => e.toJson()).toList(),
      "roles": roles?.map((e) => e.toJson()).toList(),
    };
  }
}

class BoardLead {
  final int? boardId;
  final String? boardLabel;

  BoardLead({this.boardId, this.boardLabel});

  factory BoardLead.fromJson(Map<String, dynamic> json) {
    return BoardLead(
      boardId: json['board_Id'],
      boardLabel: json['board_lable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "board_Id": boardId,
      "board_lable": boardLabel,
    };
  }
}

class MostExperienceSubject {
  final int? id;
  final String? subjectName;

  MostExperienceSubject({this.id, this.subjectName});

  factory MostExperienceSubject.fromJson(Map<String, dynamic> json) {
    return MostExperienceSubject(
      id: json['mostexperiensubjects_id'],
      subjectName: json['subjectname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mostexperiensubjects_id": id,
      "subjectname": subjectName,
    };
  }
}

class SubscriptionCategory {
  final int? id;
  final String? subscriptionType;
  final List<SubscriptionPlan>? subscriptionPlans;

  SubscriptionCategory(
      {this.id, this.subscriptionType, this.subscriptionPlans});

  factory SubscriptionCategory.fromJson(Map<String, dynamic> json) {
    return SubscriptionCategory(
      id: json['id'],
      subscriptionType: json['subscription_type'],
      subscriptionPlans: (json['subscription_plans'] as List<dynamic>?)
          ?.map((e) => SubscriptionPlan.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subscription_type": subscriptionType,
      "subscription_plans": subscriptionPlans?.map((e) => e.toJson()).toList(),
    };
  }
}

class SubscriptionPlan {
  final int? id;
  final int? subscriptionCategoryId;
  final int? durationMonth;
  final String? price;
  final String? description;
  final String? createdAt;

  SubscriptionPlan({
    this.id,
    this.subscriptionCategoryId,
    this.durationMonth,
    this.price,
    this.description,
    this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      subscriptionCategoryId: json['subscription_category_id'],
      durationMonth: json['duration_month'],
      price: json['price'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subscription_category_id": subscriptionCategoryId,
      "duration_month": durationMonth,
      "price": price,
      "description": description,
      "created_at": createdAt,
    };
  }
}

class Role {
  final int? id;
  final String? name;
  final String? slug;

  Role({this.id, this.name, this.slug});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
    };
  }
}

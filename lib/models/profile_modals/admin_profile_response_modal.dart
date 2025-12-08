class AdminProfileResponseModel {
  final bool success;
  final AdminProfileData? data;
  final String message;

  AdminProfileResponseModel({
    required this.success,
    this.data,
    required this.message,
  });

  factory AdminProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileResponseModel(
      success: json['success'] == true || json['success'] == 1,
      data: json['data'] != null
          ? AdminProfileData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

// class AdminProfileData {
//   final int? tutorburoId;
//   final int? tutorburoProfileId;
//   final String? tutorburoName;
//   final String? tutorburoMobile;
//   final double? totalCoins;
//   final double? totalSpentCoins;
//   final double? totalAvailableCoins;
//   final int? tutorburoProfileStatus;
//   final String? profilePicture;
//   final String? agencyLogo;
//   final String? fullName;
//   final String? phone;
//   final String? email;
//   final String? agencyName;
//   final String? yearInBusiness;
//   final String? fbLink;
//   final String? instaLink;
//   final String? telLink;
//   final String? location;
//   final String? state;
//   final String? accountHolderName;
//   final String?   bankName;
//   final String? accountNumber;
//   final String? ifscCode;
//   final int? placeId;
//   final double? latitude;
//   final double? longitude;
//   final String? createdAt;
//   final String? updatedAt;

//   AdminProfileData({
//     this.tutorburoId,
//     this.tutorburoProfileId,
//     this.tutorburoName,
//     this.tutorburoMobile,
//     this.totalCoins,
//     this.totalSpentCoins,
//     this.totalAvailableCoins,
//     this.tutorburoProfileStatus,
//     this.profilePicture,
//     this.agencyLogo,
//     this.fullName,
//     this.phone,
//     this.email,
//     this.agencyName,
//     this.yearInBusiness,
//     this.fbLink,
//     this.instaLink,
//     this.telLink,
//     this.location,
//     this.state,
//     this.accountHolderName,
//     this.bankName,
//     this.accountNumber,
//     this.ifscCode,
//     this.placeId,
//     this.latitude,
//     this.longitude,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory AdminProfileData.fromJson(Map<String, dynamic> json) {
//     int? _int(dynamic v) {
//       if (v == null) return null;
//       if (v is int) return v;
//       if (v is String && v.isNotEmpty) return int.tryParse(v);
//       if (v is double) return v.toInt();
//       return null;
//     }

//     double? _double(dynamic v) {
//       if (v == null) return null;
//       if (v is double) return v;
//       if (v is int) return v.toDouble();
//       if (v is String && v.isNotEmpty) return double.tryParse(v);
//       return null;
//     }

//     String? _str(dynamic v) => v == null ? null : v.toString();

//     return AdminProfileData(
//       tutorburoId: _int(json['tutorburo_id'] ?? json['id']),
//       tutorburoProfileId: _int(json['tutorburo_profile_id'] ?? json['profile_id']),
//       tutorburoName: _str(json['tutorburo_name'] ?? json['name']),
//       tutorburoMobile:
//           _str(json['tutorburo_mobile'] ?? json['mobile'] ?? json['tutorbureau_number']),
//       totalCoins: _double(json['total_coins']),
//       totalSpentCoins: _double(json['total_spent_coins']),
//       totalAvailableCoins: _double(json['total_Available_coins'] ?? json['total_available_coins']),
//       tutorburoProfileStatus:
//           _int(json['tutorburo_profile_status'] ?? json['profile_status']),
//       profilePicture: _str(json['profile_picture']),
//       agencyLogo: _str(json['agency_logo']),
//       fullName: _str(json['full_name']),
//       phone: _str(json['phone']),
//       email: _str(json['email']),
//       agencyName: _str(json['agency_name']),
//       yearInBusiness: _str(json['year_in_bussiness'] ?? json['year_in_business']),
//       fbLink: _str(json['fb_link']),
//       instaLink: _str(json['insta_link']),
//       telLink: _str(json['tel_link']),
//       location: _str(json['location']),
//       state: _str(json['state']),
//       accountHolderName: _str(json['account_holder_name']),
//       bankName: _str(json['bank_name']),
//       accountNumber: _str(json['account_number']),
//       ifscCode: _str(json['ifsc_code']),
//       placeId: _int(json['place_id']),
//       latitude: _double(json['latitude']),
//       longitude: _double(json['longitude']),
//       createdAt: _str(json['created_at']),
//       updatedAt: _str(json['updated_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'tutorburo_id': tutorburoId,
//       'tutorburo_profile_id': tutorburoProfileId,
//       'tutorburo_name': tutorburoName,
//       'tutorburo_mobile': tutorburoMobile,
//       'total_coins': totalCoins,
//       'total_spent_coins': totalSpentCoins,
//       'total_Available_coins': totalAvailableCoins,
//       'tutorburo_profile_status': tutorburoProfileStatus,
//       'profile_picture': profilePicture,
//       'agency_logo': agencyLogo,
//       'full_name': fullName,
//       'phone': phone,
//       'email': email,
//       'agency_name': agencyName,
//       'year_in_bussiness': yearInBusiness,
//       'fb_link': fbLink,
//       'insta_link': instaLink,
//       'tel_link': telLink,
//       'location': location,
//       'state': state,
//       'account_holder_name': accountHolderName,
//       'bank_name': bankName,
//       'account_number': accountNumber,
//       'ifsc_code': ifscCode,
//       'place_id': placeId,
//       'latitude': latitude,
//       'longitude': longitude,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }


class AdminProfileData {
  final int? tutorburoId;
  final int? tutorburoProfileId;
  final String? tutorburoName;
  final String? tutorburoMobile;
  final String? totalCoins;
  final String? totalSpentCoins;
  final String? totalAvailableCoins;
  final int? tutorburoProfileStatus;
  final String? profilePicture;
  final String? agencyLogo;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? agencyName;
  final String? yearInBussiness;
  final String? fbLink;
  final String? instaLink;
  final String? telLink;
  final String? location;
  final String? state;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? placeId;
  final String? latitude;
  final String? longitude;
  final String? pincode;

  AdminProfileData({
    this.tutorburoId,
    this.tutorburoProfileId,
    this.tutorburoName,
    this.tutorburoMobile,
    this.totalCoins,
    this.totalSpentCoins,
    this.totalAvailableCoins,
    this.tutorburoProfileStatus,
    this.profilePicture,
    this.agencyLogo,
    this.fullName,
    this.phone,
    this.email,
    this.agencyName,
    this.yearInBussiness,
    this.fbLink,
    this.instaLink,
    this.telLink,
    this.location,
    this.state,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.placeId,
    this.latitude,
    this.longitude,
    this.pincode,
  });

  factory AdminProfileData.fromJson(Map<String, dynamic> json) {
    return AdminProfileData(
      tutorburoId: json['tutorburo_id'] is int
          ? json['tutorburo_id'] as int
          : int.tryParse('${json['tutorburo_id'] ?? ''}'),
      tutorburoProfileId: json['tutorburo_profile_id'] is int
          ? json['tutorburo_profile_id'] as int
          : int.tryParse('${json['tutorburo_profile_id'] ?? ''}'),
      tutorburoName: json['tutorburo_name']?.toString(),
      tutorburoMobile: json['tutorburo_mobile']?.toString(),
      totalCoins: json['total_coins']?.toString(),
      totalSpentCoins: json['total_spent_coins']?.toString(),
      totalAvailableCoins: json['total_Available_coins']?.toString(),
      tutorburoProfileStatus: (json['tutorburo_profile_status'] != null)
          ? (json['tutorburo_profile_status'] is int
              ? json['tutorburo_profile_status'] as int
              : int.tryParse('${json['tutorburo_profile_status']}'))
          : (json['profile_status'] is int
              ? json['profile_status'] as int
              : int.tryParse('${json['profile_status'] ?? ''}')),
      profilePicture: json['profile_picture']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      agencyName: json['agency_name']?.toString(),
      yearInBussiness: json['year_in_bussiness']?.toString(),
      fbLink: json['fb_link']?.toString(),
      instaLink: json['insta_link']?.toString(),
      telLink: json['tel_link']?.toString(),
      location: json['location']?.toString(),
      state: json['state']?.toString(),
      accountHolderName: json['account_holder_name']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      placeId: json['place_id']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      pincode: json['pincode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorburo_id': tutorburoId,
      'tutorburo_profile_id': tutorburoProfileId,
      'tutorburo_name': tutorburoName,
      'tutorburo_mobile': tutorburoMobile,
      'total_coins': totalCoins,
      'total_spent_coins': totalSpentCoins,
      'total_Available_coins': totalAvailableCoins,
      'tutorburo_profile_status': tutorburoProfileStatus,
      'profile_picture': profilePicture,
      'agency_logo': agencyLogo,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'agency_name': agencyName,
      'year_in_bussiness': yearInBussiness,
      'fb_link': fbLink,
      'insta_link': instaLink,
      'tel_link': telLink,
      'location': location,
      'state': state,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'place_id': placeId,
      'latitude': latitude,
      'latitude': latitude,
      'longitude': longitude,
      'pincode': pincode,
    };
  }
}

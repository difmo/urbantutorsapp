class NearbyStudent {
  final int id;
  final String name;
  final String mobile;
  final String subject;
  final double distanceKm;
  final double latitude;
  final double longitude;

  NearbyStudent({
    required this.id,
    required this.name,
    required this.mobile,
    required this.subject,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
  });

  factory NearbyStudent.fromJson(Map<String, dynamic> j) {
    num n(dynamic v) => v is num ? v : (num.tryParse('$v') ?? 0);
    String s(dynamic v) => (v ?? '').toString();

    return NearbyStudent(
      id: n(j['id']).toInt(),
      name: s(j['name'].toString().isNotEmpty ? j['name'] : j['student_name']),
      mobile: s(j['mobile'].toString().isNotEmpty ? j['mobile'] : j['user_mobile']),
      subject: s(j['subject'] ?? j['course'] ?? j['class'] ?? ''),
      distanceKm: n(j['distance'] ?? j['distance_km']).toDouble(),
      latitude: n(j['latitude']).toDouble(),
      longitude: n(j['longitude']).toDouble(),
    );
  }
}

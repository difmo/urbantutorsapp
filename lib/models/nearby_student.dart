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
    num _n(dynamic v) => v is num ? v : (num.tryParse('$v') ?? 0);
    String _s(dynamic v) => (v ?? '').toString();

    return NearbyStudent(
      id: _n(j['id']).toInt(),
      name: _s(j['name'].toString().isNotEmpty ? j['name'] : j['student_name']),
      mobile: _s(j['mobile'].toString().isNotEmpty ? j['mobile'] : j['user_mobile']),
      subject: _s(j['subject'] ?? j['course'] ?? j['class'] ?? ''),
      distanceKm: _n(j['distance'] ?? j['distance_km']).toDouble(),
      latitude: _n(j['latitude']).toDouble(),
      longitude: _n(j['longitude']).toDouble(),
    );
  }
}

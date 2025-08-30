// lib/models/pay_course_models.dart
class PayCourse {
  final int id;
  final String? image;      // filename or full URL
  final String? pdf;        // full URL or null
  final String courseName;
  final int number;
  final double rating;
  final int coins;
  final String description;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PayCourse({
    required this.id,
    required this.image,
    required this.pdf,
    required this.courseName,
    required this.number,
    required this.rating,
    required this.coins,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
  

      factory PayCourse.fromJson(Map<String, dynamic> j) {
    double _toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;






 
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse('$v');
    }


    return PayCourse(
      id: _toInt(j['id']),
      image: j['image']?.toString(),
      pdf: j['pdf']?.toString(),
      courseName: j['course_name']?.toString() ?? '',
      number: _toInt(j['number']),
      rating: _toDouble(j['rating']),
      coins: _toInt(j['coins']),
      description: j['description']?.toString() ?? '',
      status: _toInt(j['status']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
    );
  }

            Object? toJson() {
              return {
                'id': id,
                'image': image,
                'pdf': pdf,
                'course_name': courseName,
                'number': number,
                'rating': rating,
                'coins': coins,
                'description': description,
                'status': status,
                'created_at': createdAt?.toIso8601String(),
                'updated_at': updatedAt?.toIso8601String(),
              };
            }

            
}

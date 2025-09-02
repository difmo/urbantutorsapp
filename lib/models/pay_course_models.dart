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
    double toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    int toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;






 
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse('$v');
    }


    return PayCourse(
      id: toInt(j['id']),
      image: j['image']?.toString(),
      pdf: j['pdf']?.toString(),
      courseName: j['course_name']?.toString() ?? '',
      number: toInt(j['number']),
      rating: toDouble(j['rating']),
      coins: toInt(j['coins']),
      description: j['description']?.toString() ?? '',
      status: toInt(j['status']),
      createdAt: toDate(j['created_at']),
      updatedAt: toDate(j['updated_at']),
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

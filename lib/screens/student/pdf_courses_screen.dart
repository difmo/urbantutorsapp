// lib/screens/student/pay_courses_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:url_launcher/url_launcher.dart';


class PDFCoursesScreen extends StatefulWidget {
  const PDFCoursesScreen({super.key});

  @override
  State<PDFCoursesScreen> createState() => _PDFCoursesScreenState();
}

class _PDFCoursesScreenState extends State<PDFCoursesScreen> {
  final PayCourseController _payCourseController =
      Get.find<PayCourseController>();

  static const blue = Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    print("Loaded courses:");
    for (var course in _payCourseController.courses) {
      print(course.toJson());
    }
    // Use a logging framework if needed for debugging, or remove these lines in production.
    // debugPrint(_payCourseController.courses.toString());
    // debugPrint(_payCourseController.isLoading.toString());
    // debugPrint(_payCourseController.error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: blue,
        elevation: 0,
      ),
      body: Obx(() {
        if (_payCourseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_payCourseController.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 32),
                const SizedBox(height: 8),
                Text(_payCourseController.error.value,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _payCourseController.load,
                    child: const Text('Retry')),
              ],
            ),
          );
        }
        if (_payCourseController.courses.isEmpty) {
          return const Center(child: Text('No courses available'));
        }

        return RefreshIndicator(
          onRefresh: _payCourseController.refreshNow,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: _payCourseController.courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = _payCourseController.courses[i];
              return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  item.courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B45),
                  ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6E7A8A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                  children: [
                    _CoinsChip(coins: item.coins),
                    const Spacer(),
                    Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222B45),
                      ),
                      ),
                    ],
                    ),
                  ],
                  ),
                  const SizedBox(height: 12),
                  if (item.pdf != null && item.pdf!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Open PDF'),
                    onPressed: () => _openPdf(item.pdf!),
                    ),
                  )
                  else
                  const Text(
                    'PDF not available',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
                ),
              ),
              );
            },
            
          ),
        );
      }),
    );
  }

  Future<void> _openPdf(String url) async {
    // If no scheme, treat as relative
    Uri uri = Uri.tryParse(url)?.hasScheme == true
        ? Uri.parse(url)
        : Uri.parse(
            'https://urbantutors.pro/public/admin/uploads/paycourse/${Uri.encodeComponent(url)}',
          );

    // Rebuild to ensure proper encoding of path/query
    uri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path, // already encoded by Uri
      query: uri.query,
      fragment: uri.fragment,
    );

    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CoinsChip extends StatelessWidget {
  const _CoinsChip({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final isFree = coins <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isFree ? const Color(0xFFB2DFDB) : const Color(0xFFFFE0B2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on,
              size: 16,
              color:
                  isFree ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Text(isFree ? 'Free' : '$coins coins',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    isFree ? const Color(0xFF065F46) : const Color(0xFF92400E),
              )),
        ],
      ),
    );
  }
}

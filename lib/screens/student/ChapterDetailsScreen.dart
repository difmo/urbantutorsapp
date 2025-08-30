// lib/screens/student/chapter_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/services/notes_service.dart'; // only for buildImageUrl()

class ChapterDetailsScreen extends StatefulWidget {
  final int chapterId;
  const ChapterDetailsScreen({super.key, required this.chapterId});

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  late final LeadMetaController _lead;
  static const blue = Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _lead = Get.isRegistered<LeadMetaController>()
        ? Get.find<LeadMetaController>()
        : Get.put(LeadMetaController());
    _load(); // initial fetch
  }

  Future<void> _load() =>
      _lead.loadChaptersDetails(chapterId: widget.chapterId, type: 'Note');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar:
          AppBar(backgroundColor: blue, title: const Text('Chapter Details')),
      body: Obx(() {
        if (_lead.isFetchingChapterDetails.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // If an error occurred and no data is present
        if (_lead.error.isNotEmpty && _lead.chapterDetails.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 40),
                  const SizedBox(height: 8),
                  Text(_lead.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final d = _lead.chapterDetails.value; // ChapterDetailsResponse?
        if (d == null) {
          return const Center(child: Text('No details found'));
        }

        return RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 12,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('${d.boardName} • ${d.className}',
                    //     style: const TextStyle(fontWeight: FontWeight.w700)),
                    // const SizedBox(height: 4),
                    // Text('${d.subjectName} → ${d.chapterName}',
                    //     style: const TextStyle(color: Color(0xFF4B5563))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // if (d.items.isEmpty)
              //   const Text('No content available for this chapter.',
              //       style: TextStyle(color: Color(0xFF6B7280))),

              // if (d.items.isNotEmpty)
              //   ListView.separated(
              //     shrinkWrap: true,
              //     physics: const NeverScrollableScrollPhysics(),
              //     itemCount: d.items.length,
              //     separatorBuilder: (_, __) => const SizedBox(height: 12),
              //     itemBuilder: (_, i) {
              //       final it = d.items[i]; // your detail item model
              //       final imgUrl = NotesService.buildImageUrl(d.imageBaseUrl, it.image);

              //       return Container(
              //         padding: const EdgeInsets.all(12),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(12),
              //           border: Border.all(color: const Color(0xFFE5E7EB)),
              //         ),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             if (it.heading.isNotEmpty)
              //               Text(it.heading,
              //                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              //             if (it.heading.isNotEmpty) const SizedBox(height: 8),

              //             if (imgUrl.isNotEmpty)
              //               ClipRRect(
              //                 borderRadius: BorderRadius.circular(10),
              //                 child: AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Image.network(
              //                     imgUrl,
              //                     fit: BoxFit.cover,
              //                     errorBuilder: (_, __, ___) => Container(
              //                       color: const Color(0xFFF1F5F9),
              //                       alignment: Alignment.center,
              //                       child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             if (imgUrl.isNotEmpty) const SizedBox(height: 10),

              //             if (it.content.isNotEmpty)
              //               Text(it.content,
              //                   style: const TextStyle(height: 1.35, color: Color(0xFF374151))),
              //           ],
              //         ),
              //       );
              //     },
              //   ),
            ],
          ),
        );
      }),
    );
  }
}

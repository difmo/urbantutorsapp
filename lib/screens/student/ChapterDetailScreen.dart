import 'package:flutter/material.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';

class ChapterDetailScreen extends StatelessWidget {
  final ChapterDetails details;
  const ChapterDetailScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(details.chapterName ?? "Chapter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(details.chapterName ?? "No details available"),
      ),
    );
  }
}

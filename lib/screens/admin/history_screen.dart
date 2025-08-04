import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class AdminHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> historyList = []; // dummy list, replace with real data

  AdminHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: primary,
      ),
      body: historyList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/icons/animation/empty.json',
                    width: 250,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: historyList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      item['studentName'] ?? '',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                        '${item['subject']} | ${item['location']} | ${item['date']}'),
                    trailing: Text(
                      item['status'] ?? '',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/tutor_pro_controller.dart';
import 'package:urbantutorsapp/models/nearby_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class TutorChatScreen extends StatefulWidget {
  const TutorChatScreen({
    super.key,
    this.latitude = 28.0014, // you can inject live GPS here
    this.longitude = 75.6663, // you can inject live GPS here
    this.radiusKm = 10,
    this.subscriptionPlanId = 1, // default Pro plan
  });

  final double latitude;
  final double longitude;
  final int radiusKm;
  final int subscriptionPlanId;

  @override
  State<TutorChatScreen> createState() => _TutorChatScreenState();
}

class _TutorChatScreenState extends State<TutorChatScreen> {
  late final TutorProController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<TutorProController>()
        ? Get.find<TutorProController>()
        : Get.put(TutorProController());

    // Defer network + Rx updates to next frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.load(
        latitude: widget.latitude,
        longitude: widget.longitude,
        radiusKm: widget.radiusKm,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_c.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 42),
                  const SizedBox(height: 10),
                  Text(_c.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _c.load(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      radiusKm: widget.radiusKm,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!_c.hasPro.value) {
          return _ProUpsell(
            onBuy: _c.isPurchasing.value
                ? null
                : () => _c.buyProAndReload(
                      subscriptionPlanId: widget.subscriptionPlanId,
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      radiusKm: widget.radiusKm,
                    ),
            busy: _c.isPurchasing.value,
          );
        }

        // Has Pro → show nearby students
        if (_c.students.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _c.load(
              latitude: widget.latitude,
              longitude: widget.longitude,
              radiusKm: widget.radiusKm,
            ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.black26),
                      SizedBox(height: 10),
                      Text('No students found nearby',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _c.load(
            latitude: widget.latitude,
            longitude: widget.longitude,
            radiusKm: widget.radiusKm,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            itemCount: _c.students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NearbyStudentCard(student: _c.students[i]),
          ),
        );
      }),
    );
  }
}

/// ======= UI PARTS =======

class _ProUpsell extends StatelessWidget {
  const _ProUpsell({required this.onBuy, required this.busy});
  final VoidCallback? onBuy;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Get Pro Membership to unlock:\n• Free chat with students/parents\n• Top listing visibility\n• Visible contact number for one year",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: 350,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.workspace_premium, size: 24),
                label: Text(
                  busy ? 'Processing...' : 'Get Pro Membership Now',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: onBuy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyStudentCard extends StatelessWidget {
  const _NearbyStudentCard({required this.student});
  final NearbyStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryColor.withOpacity(.12),
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.subject.isEmpty
                            ? 'Subject not specified'
                            : student.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${student.distanceKm.toStringAsFixed(1)} km away',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      student.mobile.isEmpty ? 'Hidden' : student.mobile,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            onPressed: () {
              // TODO: navigate to your actual chat screen with this student
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Open chat with ${student.name}')),
              );
            },
          ),
        ],
      ),
    );
  }
}

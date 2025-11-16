import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/ChatScreen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class ChatUserListScreen extends StatefulWidget {
  const ChatUserListScreen({super.key});

  @override
  State<ChatUserListScreen> createState() => _ChatUserListScreenState();
}

class _ChatUserListScreenState extends State<ChatUserListScreen> {
  final MasterDataController _master = Get.isRegistered<MasterDataController>()
      ? Get.find<MasterDataController>()
      : Get.put(MasterDataController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (_master.masterData.value == null) {
          await _master.fetchMasterData();
        }
      } catch (e, st) {
        debugPrint('init hydrate error: $e\n$st');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          // If loading or data is null
          if (_master.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final teachers = _master.masterData.value?.data.teachers ?? [];

          if (teachers.isEmpty) {
            return const Center(child: Text("No teachers available"));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: teachers.length,
            separatorBuilder: (_, __) => const Divider(indent: 72, height: 1),
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              final name = teacher.name ?? 'Unknown';
              final email = teacher.mobile ?? '';
              final profileChar = name.isNotEmpty ? name[0].toUpperCase() : '?';
              final lastMessage = teacher.teacherId == 1 ?? 'Tap to chat';

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(teacherName: name),
                    ),
                  );
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  // test
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      profileChar,
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  email,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              );
            },
          );
        }),
      ),
    );
  }
}

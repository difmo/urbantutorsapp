import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/home_router.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TeacherPendingScreen extends StatefulWidget {
  const TeacherPendingScreen({super.key});

  @override
  State<TeacherPendingScreen> createState() => _TeacherPendingScreenState();
}

class _TeacherPendingScreenState extends State<TeacherPendingScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _isChecking = false;
  late final ProfileUpdateController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _silentCheck();
      // Auto-poll every 3 seconds so as soon as admin verifies on website,
      // it immediately navigates to TutorDashboard!
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _silentCheck();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentCheck();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleStatusRouting(int status, {bool showStillPendingMessage = false}) async {
    if (!mounted) return;
    if (status == 2) {
      // Admin verified! Immediately dismiss pending screen & navigate to TutorDashboard
      _pollTimer?.cancel();
      await StorageService.saveIsProfileStatus(2);
      if (!mounted) return;
      Get.snackbar(
        'Verified',
        '🎉 Your profile has been verified!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const TutorDashboard());
    } else if (status == 0) {
      // Profile rejected or incomplete
      _pollTimer?.cancel();
      await StorageService.saveIsProfileStatus(0);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => homeScreenFor(Roles.tutor, 0)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your profile needs to be completed again.'),
        ),
      );
    } else {
      // Still status == 1 (under verification)
      if (showStillPendingMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your profile is still under verification. Kindly wait..."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _silentCheck() async {
    if (!mounted || _isChecking) return;
    try {
      await _controller.fetchProfileForTutor();
      final status = _controller.tutorprofileData.value?.profileStatus;
      if (status != null && status != 1) {
        await _handleStatusRouting(status);
      }
    } catch (_) {}
  }

  Future<void> _manualRefresh() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      await _controller.fetchProfileForTutor();
      final status = _controller.tutorprofileData.value?.profileStatus;
      if (status != null && status != 1) {
        await _handleStatusRouting(status);
      } else {
        await _handleStatusRouting(1, showStillPendingMessage: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      size: 64,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your profile is under verification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Kindly Wait...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Our team will verify your account within 24 hours,\nthen you can start exploring all opportunities",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _manualRefresh,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isChecking ? "Checking Status..." : "Refresh Status",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

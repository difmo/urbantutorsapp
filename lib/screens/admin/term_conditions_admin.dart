import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_constants.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool isStudentSelected = true;

  final TextEditingController studentController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();

  @override
  void dispose() {
    studentController.dispose();
    teacherController.dispose();
    super.dispose();
  }

  void saveTerms() {
    final content = isStudentSelected
        ? studentController.text
        : teacherController.text;

    final userType = isStudentSelected ? 'Student' : 'Teacher';

    // TODO: Replace with API or storage call
    Get.snackbar(
      'Success',
      '$userType Terms & Conditions saved!',
      backgroundColor: Colors.green.shade100,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F1FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Row(
              children: [
                _tabButton('Student Terms', isStudentSelected, () {
                  setState(() => isStudentSelected = true);
                }),
                const SizedBox(width: 12),
                _tabButton('Teacher Terms', !isStudentSelected, () {
                  setState(() => isStudentSelected = false);
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Label
            Text(
              'Edit Terms & Conditions',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            // Editor Box
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller:
                    isStudentSelected ? studentController : teacherController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your terms & conditions here...',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTerms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tab Button Widget
  Widget _tabButton(String label, bool isSelected, VoidCallback onTap) {
    final Color primary = AppColors.primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.white,
            border: Border.all(color: primary),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : primary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

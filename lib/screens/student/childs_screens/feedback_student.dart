import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class FeedbackStudent extends StatefulWidget {
  const FeedbackStudent({super.key});

  @override
  State<FeedbackStudent> createState() => _FeedbackStudentState();
}

class _FeedbackStudentState extends State<FeedbackStudent> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: call your API here with _titleCtrl.text and _descCtrl.text

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted")),
    );
    _titleCtrl.clear();
    _descCtrl.clear();
  }

  InputDecoration _dec({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      counterText: '',
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 76,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Feedback",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Text("Title",textAlign: TextAlign.left,),
                //   ],
                // ),
                //     const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: _dec(label: 'Title : ', hint: 'Main heading'),
                  maxLength: 100,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Title is required';
                    if (t.length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text("Description :"),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: _dec(label: '', hint: 'Write your feedback'),
                  maxLines: 8,

                  maxLength: 999,
                  scrollPadding: EdgeInsets.all(0),
                  textAlignVertical:
                      TextAlignVertical.top, // 👈 text starts at top
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Description is required';
                    if (t.length < 10) return 'Please add a bit more detail';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitFeedback,
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

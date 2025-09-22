import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class SupportTutor extends StatelessWidget {
  const SupportTutor({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Need Assistance, We're here to help !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              " Connect us through  below options below ...",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _contactOption(
                    icon: Icons.chat,
                    title: "Live Chat",
                    subtitle: "Get instant support",
                    onTap: () {
                      // TODO: open your in-app chat screen
                    },
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _contactOption(
                    icon: Icons.email_outlined,
                    title: "Email Us",
                    subtitle: "support@urbantutors.pro",
                    onTap: () => {
// launchUrl(Uri.parse('mailto:support@urbantutors.com')),
                    },
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            // _contactOption(
            //   icon: Icons.phone,
            //   title: "Call Us",
            //   subtitle: "+91 95826 99555",
            //   onTap: () {},
            //   color: Colors.green,
            // ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // FAQ Section
            const Text(
              "Frequently Asked Questions...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _faqItem("How can I upgrade my plan?"),
            _faqItem("Where can I access my course notes?"),
            _faqItem("How do I connect with a private tutor?"),
            _faqItem("What payment methods are accepted?"),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // Submit a Query
            const Text(
              "Submit Your Queries here...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your issue or question here...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              colors: [AppColors.accentColor.withOpacity(.18), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(width: 1, color: AppColors.primaryColor)),
        padding: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              Text(subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
      title: Text(question),
      onTap: () {},
    );
  }
}

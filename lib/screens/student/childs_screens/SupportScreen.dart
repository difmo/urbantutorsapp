import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
     
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Need Assistance?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "We're here to help! Contact us through the options below or browse our FAQ.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Contact Options
          _contactOption(
            icon: Icons.chat,
            title: "Live Chat",
            subtitle: "Get instant support from our team",
            onTap: () {},
            color: primaryColor,
          ),
          _contactOption(
            icon: Icons.email_outlined,
            title: "Email Us",
            subtitle: "support@urbantutors.com",
            onTap: () {},
            color: Colors.green,
          ),
          _contactOption(
            icon: Icons.phone,
            title: "Call Us",
            subtitle: "+91 98765 43210",
            onTap: () {},
            color: Colors.green,
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // FAQ Section
          const Text(
            "Frequently Asked Questions",
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
            "Submit a Query",
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
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _faqItem(String question) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
      title: Text(question),
      onTap: () {
       
      },
    );
  }
}

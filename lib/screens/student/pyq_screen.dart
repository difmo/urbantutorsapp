import 'package:flutter/material.dart';

class PyqScreen extends StatelessWidget {
  const PyqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text("PYQ's", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _sectionTitle("Select Your Board :-"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _optionCard("CBSE"),
                _optionCard("IB"),
                _optionCard("IGCSE"),
                _optionCard("ICSE"),
                _optionCard("ISC"),
                _optionCard("NIOS"),
              ],
            ),

            const SizedBox(height: 40),

            _sectionTitle("Select Your Class :-"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _optionCard("Class X"),
                _optionCard("Class XI"),
                _optionCard("Class XII"),
              ],
            ),

            const SizedBox(height: 40),

            _sectionTitle("Select Your Subject :-"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _optionCard("English"),
                _optionCard("Math"),
                _optionCard("Science"),
              ],
            ),

            const SizedBox(height: 50),

            // ----- Submit Button -----
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => null,
                  ),
                  elevation: MaterialStateProperty.all(4),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Submit button pressed")),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Section Title -----
  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.orange,
      ),
    );
  }

  // ----- Beautiful Option Card -----
  static Widget _optionCard(String title) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // TODO: Add selection logic
      },
      child: Container(
        width: 120,
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.shade100, width: 1),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
      ),
    );
  }
}

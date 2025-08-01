import 'package:flutter/material.dart';
import 'package:urbantutorsapp/widgets/searchable_location_field.dart.dart';
import '../../theme/theme_constants.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass;
  String? selectedSubject;
  String? location;
  String? phone;
  String? name;
  String? timing;
  String? remarks;
  String? coinsRequired;

  final List<String> classes = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12'
  ];
  final List<String> subjects = [
    'Math',
    'Science',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science'
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Create New Lead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionTitle("Student Details"),
              _buildTextField('Student/Parent Name', (val) => name = val),
              const SizedBox(height: 16),
              _buildTextField('Mobile Number', (val) => phone = val,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              SearchableLocationField(
                suggestions: [
                  'Delhi',
                  'Mumbai',
                  'Kolkata',
                  'Bangalore',
                  'Chennai',
                  // etc...
                ],
                onLocationSelected: (loc) => location = loc,
              ),
              const SizedBox(height: 24),
              _sectionTitle("Class & Subject"),
              _buildDropdownField(
                  'Select Class', classes, (val) => selectedClass = val),
              const SizedBox(height: 16),
              _buildDropdownField(
                  'Select Subject', subjects, (val) => selectedSubject = val),
              const SizedBox(height: 24),
              _sectionTitle("Session Info"),
              _buildTextField('Preferred Timing', (val) => timing = val),
              const SizedBox(height: 16),
              _buildTextField('Required Coins', (val) => coinsRequired = val,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('Remarks / Notes', (val) => remarks = val,
                  maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check),
                label: const Text('Submit Lead'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      validator: (value) => value == null ? 'Please select $label' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter $label' : null,
      onChanged: onSaved,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                fontSize: 16,
              )),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead submitted successfully')),
      );
      Navigator.pop(context);
    }
  }
}

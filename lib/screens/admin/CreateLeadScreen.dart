import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:urbantutorsapp/controllers/get_classes_controller.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';
import 'package:urbantutorsapp/widgets/searchable_location_field.dart.dart';
import '../../theme/theme_constants.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  final LeadCreateController leadCreateController =
      Get.put(LeadCreateController());
  final GetClassesController getClassesController =
      Get.put(GetClassesController());
  // String? selectedClass;
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
  ClassData? selectedClass;

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
  void initState() {
    getClassesController.fetchClasses().then((_) {
      print("Class list loaded:");
      for (var item in getClassesController.classList) {
        print(item.className);
      }
    });
    super.initState();
  }

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
              Obx(() {
                return _buildDropdownField1<ClassData>(
                  label: 'Select Class',
                  items: getClassesController.classList,
                  selectedItem:selectedClass,
                  itemLabel: (item) => item.className,
                  onChanged: (val) {
                    setState(() {
                      selectedClass = val;
                    });
                  },
                );
              }),
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
Widget _buildDropdownField1<T>({
  required String label,
  required List<T> items,
  required T? selectedItem,
  required String Function(T) itemLabel, // how to display the item
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    value: selectedItem,
    hint: Text(label),
    isExpanded: true,
    items: items.map((item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabel(item)), // get display name
      );
    }).toList(),
    onChanged: onChanged,
    validator: (value) => value == null ? 'Please select $label' : null,
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
      final data = leadCreateRequest(
          name: name ?? "",
          mobile: phone ?? "",
          boardId: "8",
          classId: "6",
          location: location ?? "Lucknow",
          state: 'uttar pradesh',
          mode: "Offline",
          fee: "552",
          leadId: "4",
          subjectId: "9",
          userId: "7");

      leadCreateController.createOrUpdateLead(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead submitted successfully')),
      );
      Navigator.pop(context);
    }
  }
}

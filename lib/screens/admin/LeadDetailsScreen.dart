import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/get_classes_controller.dart';
import 'package:urbantutorsapp/controllers/get_subject_controller.dart';
import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/models/get_subject_model.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/widgets/searchable_location_field.dart.dart';

class LeadDetailsScreen extends StatefulWidget {
  final String studentName;
      final String mobile;
      final String subject;
      final String classLevel;
      final String location;
      final String timing;
      final String coins;
      final String remarks;
      final String name;
      final String className;
      final String fee;
      final String mode;
      final String gender;
  const LeadDetailsScreen(
      {super.key,
      required this.studentName,
      required this.mobile,
      required this.subject,
      required this.classLevel,
      required this.location,
      required this.timing,
      required this.coins,
      required this.remarks,
      required this.name,
      required this.className,
      required this.fee,
      required this.mode,
      required this.gender});

  @override
  State<LeadDetailsScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<LeadDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeadCreateController leadCreateController =
      Get.put(LeadCreateController());
  final GetClassesController getClassesController =
      Get.put(GetClassesController());
  final GetSubjectController getSubjectController =
      Get.put(GetSubjectController());

  String? location,
      phone,
      name,
      timing,
      remarks,
      coinsRequired,
      fee,
      tutorGender;
  String? teachingMode, selectedState, maxHits, selectedSupportAgent;
  double searchRadius = 4.0;
  List<Map<String, String>> nearbyTutors = [];

  final Map<String, String> boardLeadMap = {
    "8": "CBSE",
    "9": "IB",
    "10": "IGCSE",
    "11": "ICSE",
    "12": "ISC",
    "13": "NIOS"
  };
  String? selectedBoardId;

  final List<Map<String, String>> supportAgents = [
    {'name': 'Raj', 'number': '+91 9123456780'},
    {'name': 'Neha', 'number': '+91 9876543210'},
  ];

  ClassData? selectedClass;
  SubjectData? selectedSubject;

  @override
  void initState() {
    getClassesController.fetchClasses(boardId: 1);
    getSubjectController.fetchSubjects();
    fetchTutors(searchRadius);
    super.initState();
  }

  void fetchTutors(double radius) {
    setState(() {
      searchRadius = radius;
      nearbyTutors = [
        if (radius >= 2) {'phone': '+919971225774', 'name': 'Sagar Solanki'},
        if (radius >= 3) {'phone': '+919268037284', 'name': 'Jitendra Kumar'},
        if (radius >= 4)
          {'phone': '+917982204695', 'name': 'Dashrath Kumar Singh'},
        if (radius >= 5) {'phone': '+919369617364', 'name': 'Another Tutor'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
  print(widget.className);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Create New Lead'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    'Chennai'
                  ],
                  onLocationSelected: (loc) => location = loc,
                ),
                const SizedBox(height: 24),
                _sectionTitle("Lead Info"),
                DropdownButtonFormField<String>(
                  value: selectedBoardId,
                  hint: const Text('Select Board',
                      style: TextStyle(color: Color(0xFF9B9B9B))),
                  isExpanded: true,
                  decoration: _dropdownDecoration(),
                  items: boardLeadMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedBoardId = val),
                  validator: (val) =>
                      val == null ? 'Please select Board' : null,
                ),
                const SizedBox(height: 16),
                _dropdownField(
                  label: 'Tutor Gender',
                  value: tutorGender,
                  items: ['Male', 'Female', 'Any'],
                  onChanged: (val) => setState(() => tutorGender = val),
                ),
                const SizedBox(height: 16),
                _dropdownField(
                  label: 'Teaching Mode',
                  value: teachingMode,
                  items: ['Online', 'Offline', 'Hybrid'],
                  onChanged: (val) => setState(() => teachingMode = val),
                ),
                const SizedBox(height: 16),
                _dropdownField(
                  label: 'Select State',
                  value: selectedState,
                  items: [
                    'Uttar Pradesh',
                    'Delhi',
                    'Maharashtra',
                    'Bihar',
                    'Tamil Nadu'
                  ],
                  onChanged: (val) => setState(() => selectedState = val),
                ),
                const SizedBox(height: 16),
                _buildTextField('Max Hits', (val) => maxHits = val,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                _sectionTitle("Class & Subject"),
                Obx(() {
                  return _buildDropdownField1<ClassData>(
                    label: 'Select Class',
                    items: getClassesController.classList,
                    selectedItem: selectedClass,
                    itemLabel: (item) => item.className,
                    onChanged: (val) => setState(() => selectedClass = val),
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  return _buildDropdownField1<SubjectData>(
                    label: 'Select Subject',
                    items: getSubjectController.subjectList,
                    selectedItem: selectedSubject,
                    itemLabel: (item) => item.subjectName,
                    onChanged: (val) => setState(() => selectedSubject = val),
                  );
                }),
                const SizedBox(height: 24),
                _sectionTitle("Session Info"),
                _buildTextField('Preferred Timing', (val) => timing = val),
                const SizedBox(height: 16),
                _buildTextField('Fee (₹/Hrs)', (val) => fee = val,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('Required Coins', (val) => coinsRequired = val,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('Remarks / Notes', (val) => remarks = val,
                    maxLines: 3),
                const SizedBox(height: 32),
                Text('Select Support Agent',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primary)),
                Column(
                  children: supportAgents.map((agent) {
                    final display = '${agent['name']} - ${agent['number']}';
                    return RadioListTile<String>(
                      title: Text(display),
                      value: agent['number']!,
                      groupValue: selectedSupportAgent,
                      onChanged: (val) =>
                          setState(() => selectedSupportAgent = val),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                _sectionTitle(
                    "Search Nearby Leads in Radius of [${searchRadius.toInt()} Kms]"),
                Slider(
                  value: searchRadius,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${searchRadius.toInt()} Kms',
                  activeColor: primary,
                  onChanged: fetchTutors,
                ),
                const SizedBox(height: 8),
                Column(
                  children: nearbyTutors.map((tutor) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(tutor['phone'] ?? ''),
                      subtitle: Text(tutor['name'] ?? ''),
                      trailing:
                          Icon(Icons.call, color: primary.withOpacity(0.7)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SafeArea(
                  bottom: true,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.check),
                    label: const Text('Submit Lead'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(label, style: const TextStyle(color: Color(0xFF9B9B9B))),
      isExpanded: true,
      decoration: _dropdownDecoration(),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }

  Widget _buildDropdownField1<T>({
    required String label,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: selectedItem,
      hint: Text(label, style: const TextStyle(color: Color(0xFF9B9B9B))),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9B9B9B)),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedClass == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Class')),
        );
        return;
      }

      final data = LeadCreateRequest(
        name: name ?? "",
        mobile: phone ?? "",
        boardId: selectedBoardId ?? "",
        classId: selectedClass!.classId.toString(),
        location: location ?? "",
        state: selectedState ?? "",
        mode: teachingMode ?? "",
        fee: fee ?? "",
        subjectId: selectedSubject?.subjectId.toString() ?? "",
        userId: "7",
        tutorGender: tutorGender ?? "",
        maxHits: maxHits ?? "",
        supportAgent: selectedSupportAgent ?? "",
        leadId: '',
      );

      leadCreateController.createOrUpdateLead(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead submitted successfully')),
      );
      Navigator.pop(context, true);
    }
  }
}

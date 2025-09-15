// lib/screens/tutor/create_lead_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';

class CreateLeadScreen extends StatefulWidget {
  final StudentLead? lead; // <-- if not null, we're editing
  const CreateLeadScreen({super.key, this.lead});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (use existing instances if registered)
  final LeadCreateController _leadCreate =
      Get.isRegistered<LeadCreateController>()
          ? Get.find<LeadCreateController>()
          : Get.put(LeadCreateController());
  final MasterDataController _md =
      Get.isRegistered<MasterDataController>()
          ? Get.find<MasterDataController>()
          : Get.put(MasterDataController());
  final LeadMetaController _lead =
      Get.isRegistered<LeadMetaController>()
          ? Get.find<LeadMetaController>()
          : Get.put(LeadMetaController());
  final LocationController _loc =
      Get.isRegistered<LocationController>()
          ? Get.find<LocationController>()
          : Get.put(LocationController());

  // Text fields
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final timingCtrl = TextEditingController();
  final feeCtrl = TextEditingController();
  final coinsCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final maxHitsCtrl = TextEditingController();

  // Dropdown values
  int? boardId;
  int? classId;
  int? subjectId;
  String? tutorGender;
  String? teachingMode;
  String? selectedState;
  String? selectedSupportAgent;

  bool _submitting = false;

  static const _modes = <String>['Online', 'Offline', 'Hybrid'];
  static const _genders = <String>['Male', 'Female', 'Any'];
  static const _states = <String>[
    "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Goa","Gujarat","Haryana",
    "Himachal Pradesh","Jharkhand","Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur",
    "Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan","Sikkim","Tamil Nadu",
    "Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal","Delhi"
  ];
  final List<Map<String, String>> _supportAgents = const [
    {'name': 'Raj', 'number': '+91 9123456780'},
    {'name': 'Neha', 'number': '+91 95826 99555'},
  ];

  @override
  void initState() {
    super.initState();
    // Ensure master data is present, then hydrate form from lead (if editing).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_md.masterData.value == null) {
        await _md.fetchMasterData();
      }
      await _hydrateFromLeadIfEditing();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    localityCtrl.dispose();
    timingCtrl.dispose();
    feeCtrl.dispose();
    coinsCtrl.dispose();
    remarksCtrl.dispose();
    maxHitsCtrl.dispose();
    super.dispose();
  }

  // ---------- Helpers for prefill ----------

  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  T? _firstWhereOrNull<T>(Iterable<T> it, bool Function(T) test) {
    for (final e in it) {
      if (test(e)) return e;
    }
    return null;
  }

  Future<void> _hydrateFromLeadIfEditing() async {
    final l = widget.lead;
    if (l == null) return;

    // 1) Simple text fields
    nameCtrl.text     = l.studentName ?? '';
    phoneCtrl.text    = (l.mobile ?? '').toString();
    localityCtrl.text = l.location ?? '';
    remarksCtrl.text  = l.remark ?? '';
    coinsCtrl.text    = (l.price ?? '').toString();
    // If you get timing / fee in your model, prefill here:
    // timingCtrl.text = l.timing ?? '';
    // feeCtrl.text    = l.fee ?? '';
    selectedState  = l.state;
    teachingMode   = l.mode; // "Online" / "Offline" / "Hybrid"
    // Some payloads use "type_of_teacher" — your model likely mapped to camelCase:
    // fallback to 'Any' if empty
    final g = (l.typeOfTeacher?.trim().isNotEmpty ?? false) ? l.typeOfTeacher!.trim() : 'Any';
    tutorGender = _genders.contains(g) ? g : 'Any';

    setState(() {});

    // 2) Resolve Board → Class → Subject by **name**, then set their ids.
    final boards = _md.masterData.value?.data?.boardLead ?? [];

    final boardMatch = _firstWhereOrNull(
      boards,
      (b) => _norm(b.boardLabel?.toString()) == _norm(l.boardName),
    );

    if (boardMatch != null) {
      boardId = boardMatch.boardId;
      setState(() {});
      await _lead.loadClasses(boardId!);

      final classMatch = _firstWhereOrNull(
        _lead.classes,
        (c) => _norm(c.courseName) == _norm(l.courseName),
      );

      if (classMatch != null) {
        classId = classMatch.courseId;
        setState(() {});
        await _lead.loadSubjects(classId: classId!, boardId: boardId!);

        final subjectMatch = _firstWhereOrNull(
          _lead.subjects,
          (s) => _norm(s.subjectName) == _norm(l.subjectName),
        );

        if (subjectMatch != null) {
          subjectId = subjectMatch.subjectId;
          setState(() {});
        }
      }
    }
  }

  // ---------- UI helpers ----------

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      );

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------- Submit ----------

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (boardId == null) return _toast('Please select a Board');
    if (classId == null) return _toast('Please select a Class');
    if (subjectId == null) return _toast('Please select a Subject');

    final subjectValid = _lead.subjects.any((s) => s.subjectId == subjectId);
    if (!subjectValid) {
      return _toast('Selected subject is not valid for the chosen Board/Class');
    }

    final locText = localityCtrl.text.trim();
    if (locText.isEmpty) return _toast('Please enter your Locality');

    if (teachingMode == null) return _toast('Please select Teaching Mode');
    if (selectedState == null) return _toast('Please select State');

    final phoneOk = RegExp(r'^\d{10}$').hasMatch(phoneCtrl.text.trim());
    if (!phoneOk) return _toast('Enter a valid 10-digit mobile number');

    final userId = await StorageService.getUserId();
    if (userId == null) return _toast('User not found. Please login again.');

    final req = LeadCreateRequest(
      name: nameCtrl.text.trim(),
      mobile: phoneCtrl.text.trim(),
      boardId: boardId!.toString(),
      classId: classId!.toString(),
      subjectId: subjectId!.toString(),
      location: locText,
      state: selectedState ?? '',
      mode: teachingMode ?? '',
      fee: feeCtrl.text.trim(),
      userId: userId,
      tutorGender: tutorGender ?? 'Any',
      maxHits: maxHitsCtrl.text.trim(),
      supportAgent: selectedSupportAgent ?? '',
      // IMPORTANT: pass leadId when editing so backend updates the same lead
      leadId: widget.lead?.id?.toString() ?? '',
    );

    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      await _leadCreate.createOrUpdateLead(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.lead == null
              ? 'Lead submitted successfully'
              : 'Lead updated successfully'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(widget.lead == null ? 'Create New Lead' : 'Edit Lead'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _sectionTitle('Student Details'),

                TextFormField(
                  controller: nameCtrl,
                  decoration: _dec('Student/Parent Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneCtrl,
                  decoration: _dec('Mobile Number'),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{10}$').hasMatch(v))
                          ? 'Enter 10-digit number'
                          : null,
                ),
                const SizedBox(height: 16),

                // Locality with server-backed autocomplete
                Obx(() {
                  final isLoading = _loc.isSearching.value;
                  final opts = _loc.suggestions;

                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim();
                      if (q.isEmpty) return const Iterable<String>.empty();
                      return opts;
                    },
                    onSelected: (val) {
                      localityCtrl.text = val;
                      _loc.onQueryChanged('');
                    },
                    fieldViewBuilder:
                        (context, textCtrl, focusNode, onFieldSubmitted) {
                      if (textCtrl.text != localityCtrl.text) {
                        textCtrl.text = localityCtrl.text;
                        textCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: textCtrl.text.length),
                        );
                      }
                      textCtrl.addListener(() {
                        final q = textCtrl.text;
                        if (localityCtrl.text != q) {
                          localityCtrl.text = q;
                        }
                        _loc.onQueryChanged(q);
                      });

                      return TextFormField(
                        controller: textCtrl,
                        focusNode: focusNode,
                        decoration: _dec('Locality').copyWith(
                          hintText: 'Type city/area (e.g., lko)…',
                          suffixIcon: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onFieldSubmitted: (_) => onFieldSubmitted(),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final list = options.toList();
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 280,
                              maxWidth:
                                  MediaQuery.of(context).size.width - 32,
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) => ListTile(
                                dense: true,
                                title: Text(list[i]),
                                onTap: () => onSelected(list[i]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),

                _sectionTitle('Lead Info'),

                // BOARD
                Obx(() {
                  final boards =
                      _md.masterData.value?.data?.boardLead ?? [];
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: boardId,
                    decoration: _dec('Board'),
                    items: boards
                        .map((b) => DropdownMenuItem<int>(
                              value: b.boardId,
                              child: Text(b.boardLabel?.toString() ?? ''),
                            ))
                        .toList(),
                    onChanged: (val) async {
                      setState(() {
                        boardId = val;
                        classId = null;
                        subjectId = null;
                      });
                      if (val != null) {
                        await _lead.loadClasses(val);
                      }
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),
                const SizedBox(height: 16),

                // CLASS
                Obx(() {
                  final classes = _lead.classes;
                  final fetching = _lead.isFetchingClasses.value;
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: classId,
                    decoration: _dec('Class').copyWith(
                      suffixIcon: fetching
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: classes
                        .map((c) => DropdownMenuItem<int>(
                              value: c.courseId,
                              child: Text(c.courseName),
                            ))
                        .toList(),
                    onChanged: (boardId == null)
                        ? null
                        : (val) async {
                            setState(() {
                              classId = val;
                              subjectId = null;
                            });
                            if (val != null && boardId != null) {
                              await _lead.loadSubjects(
                                  classId: val, boardId: boardId!);
                            }
                          },
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),
                const SizedBox(height: 16),

                // SUBJECT
                Obx(() {
                  final subjects = _lead.subjects;
                  final fetching = _lead.isFetchingSubjects.value;
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: subjectId,
                    decoration: _dec('Subject').copyWith(
                      suffixIcon: fetching
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: subjects
                        .map((s) => DropdownMenuItem<int>(
                              value: s.subjectId,
                              child: Text(s.subjectName),
                            ))
                        .toList(),
                    onChanged: (boardId == null || classId == null)
                        ? null
                        : (val) => setState(() => subjectId = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: tutorGender,
                  decoration: _dec('Tutor Gender'),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => tutorGender = v),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: teachingMode,
                  decoration: _dec('Teaching Mode'),
                  items: _modes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => teachingMode = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedState,
                  decoration: _dec('State'),
                  items: _states
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedState = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: maxHitsCtrl,
                  decoration: _dec('Max Hits'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                _sectionTitle('Class & Subject'),
                const SizedBox(height: 24),

                _sectionTitle('Session Info'),
                TextFormField(
                  controller: timingCtrl,
                  decoration: _dec('Preferred Timing'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: feeCtrl,
                  decoration: _dec('Fee (₹/Hrs)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: coinsCtrl,
                  decoration: _dec('Required Coins'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: remarksCtrl,
                  decoration: _dec('Remarks / Notes'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                _sectionTitle('Select Support Agent'),
                Column(
                  children: _supportAgents.map((agent) {
                    final display = '${agent['name']} - ${agent['number']}';
                    return RadioListTile<String>(
                      title: Text(display),
                      value: agent['number']!,
                      groupValue: selectedSupportAgent,
                      onChanged: (v) => setState(() => selectedSupportAgent = v),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(_submitting
                          ? (widget.lead == null ? 'Submitting…' : 'Updating…')
                          : (widget.lead == null ? 'Submit Lead' : 'Update Lead')),
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

  Widget _sectionTitle(String title) => Padding(
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

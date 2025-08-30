import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class SearchTutorScreen extends StatefulWidget {
  const SearchTutorScreen({super.key});

  @override
  State<SearchTutorScreen> createState() => _SearchTutorScreenState();
}

class _SearchTutorScreenState extends State<SearchTutorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final localityCtrl = TextEditingController();

  // Selections
  int? boardId;
  int? classId;
  int? subjectId;
  String? stateVal;
  String? modeVal;

  double _fee = 700;

  // GetX controllers (already registered in main/initialBinding)
  final MasterDataController _md = Get.find<MasterDataController>();
  final LeadMetaController _lead = Get.find<LeadMetaController>();
  final LocationController _loc = Get.find<LocationController>();

  static const _states = <String>[
    'Delhi', 'Uttar Pradesh', 'Haryana', 'Maharashtra', 'Karnataka', 'Tamil Nadu'
  ];
  static const _modes = <String>['Online', 'Offline', 'Hybrid'];

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    localityCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.2),
      ),
    );
  }

  Widget _dropdownDec(Widget child) => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: child,
      );

  Future<void> _onGetOtp() async {
    if (!_formKey.currentState!.validate()) return;

    AppLog.i('[FORM] Submit → '
        'name=${nameCtrl.text}, '
        'mobile=${mobileCtrl.text}, '
        'board=$boardId, class=$classId, subject=$subjectId, '
        'locality=${localityCtrl.text}, state=$stateVal, mode=$modeVal, '
        'fee=$_fee');

    // TODO: call your OTP API here
    Get.snackbar('OTP', 'We just sent an OTP to ${mobileCtrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4A90E2);
    const cardPadH = 16.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Search Tutors'),
        backgroundColor: blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header line (exact look)
                    SizedBox(height: 16,),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(text: 'Kindly, Fill the Form to Hire a '),
                          TextSpan(
                            text: 'TUTOR ',
                            style: TextStyle(color: Color(0xFFFF8C00)),
                          ),
                          TextSpan(text: 'Now :'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                        
                    // Name
                    TextFormField(
                      controller: nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDec('Enter your Name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                        
                    // Mobile
                    TextFormField(
                      controller: mobileCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDec('Enter 10-digit Mobile No'),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) => const SizedBox.shrink(),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.length != 10 || int.tryParse(s) == null) {
                          return 'Enter valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                        
                    // Board
                    Obx(() {
                      final boards = _md.masterData.value?.data?.boardLead ?? [];
                      return _dropdownDec(
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: boardId,
                          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select Board'),
                          items: boards
                              .map((b) => DropdownMenuItem<int>(
                                    value: (b.boardId is int) ? b.boardId : int.tryParse('${b.boardId}'),
                                    child: Text(b.boardLabel?.toString() ?? '',
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            AppLog.i('[UI] Board changed → $val');
                            setState(() {
                              boardId = val;
                              classId = null;
                              subjectId = null;
                            });
                            if (val != null) _lead.loadClasses(val);
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                        
                    // Class
                    Obx(() {
                      final classes = _lead.classes;
                      final fetching = _lead.isFetchingClasses.value;
                      return _dropdownDec(
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: classId,
                          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select Class').copyWith(
                            suffixIcon: fetching
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : null,
                          ),
                          items: classes
                              .map((c) => DropdownMenuItem<int>(
                                    value: c.courseId,
                                    child: Text(c.courseName, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (boardId == null)
                              ? null
                              : (val) {
                                  AppLog.i('[UI] Class changed → $val');
                                  setState(() {
                                    classId = val;
                                    subjectId = null;
                                  });
                                  if (val != null && boardId != null) {
                                    _lead.loadSubjects(classId: val, boardId: boardId!);
                                  }
                                },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                        
                    // Subject
                    Obx(() {
                      final subjects = _lead.subjects;
                      final fetching = _lead.isFetchingSubjects.value;
                      return _dropdownDec(
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: subjectId,
                          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select Subject').copyWith(
                            suffixIcon: fetching
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : null,
                          ),
                          items: subjects
                              .map((s) => DropdownMenuItem<int>(
                                    value: s.subjectId,
                                    child: Text(s.subjectName, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (classId == null || boardId == null)
                              ? null
                              : (val) {
                                  AppLog.i('[UI] Subject changed → $val');
                                  setState(() => subjectId = val);
                                },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                        
                    // Locality (Autocomplete + POST)
                    Obx(() {
                      final loading = _loc.isSearching.value;
                      final opts = _loc.suggestions;
                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue tev) {
                          final q = tev.text.trim();
                          if (q.isEmpty) return const Iterable<String>.empty();
                          return opts; // already filtered by server
                        },
                        onSelected: (val) {
                          AppLog.i('[UI] Locality selected → $val');
                          localityCtrl.text = val;
                          _loc.onQueryChanged('');
                        },
                        fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
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
                            _loc.onQueryChanged(q); // debounced POST
                          });
                          return TextFormField(
                            controller: textCtrl,
                            focusNode: focusNode,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDec('Enter your Locality').copyWith(
                              suffixIcon: loading
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  : const Icon(Icons.location_on_outlined, color: Color(0xFF9CA3AF)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            onFieldSubmitted: (_) => onFieldSubmitted(),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          final list = options.toList();
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(10),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 280,
                                  maxWidth: MediaQuery.of(context).size.width - 48,
                                ),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
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
                    const SizedBox(height: 10),
                        
                    // State
                    _dropdownDec(
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: stateVal,
                        icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF9CA3AF)),
                        decoration: _fieldDec('Select State'),
                        items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => stateVal = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                        
                    // Mode
                    _dropdownDec(
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: modeVal,
                        icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF9CA3AF)),
                        decoration: _fieldDec('Select Mode'),
                        items: _modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (v) => setState(() => modeVal = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                        
                    // Fees slider with compact look
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Per Hour Fees :',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                  ),
                                  child: Slider(
                                    value: _fee,
                                    min: 200,
                                    max: 3000,
                                    divisions: 56,
                                    activeColor: blue,
                                    onChanged: (v) => setState(() => _fee = v),
                                  ),
                                ),
                              ),
                              Text(
                                '₹${_fee.round()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                        
                    // Get OTP (small, left-aligned like screenshot)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 42,
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: _onGetOtp,
                          child: const Text('Get OTP',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

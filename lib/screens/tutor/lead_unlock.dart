import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';

String _resolveLeadNumber(TutorLead lead, [GrabLead? grabbed]) {
  bool isValid(String? s) {
    if (s == null) return false;
    final t = s.trim();
    if (t.isEmpty || t == 'null' || t == '0' || t == '—') return false;
    final digits = t.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 6;
  }

  // 1. PRIORITY 1: The exact contact number added in the lead!
  if (isValid(lead.mobile)) {
    return lead.mobile.trim();
  }

  // 2. PRIORITY 2: From grabbed lead (studentMobile resolves 'mobile' / 'student_mobile')
  if (grabbed != null && isValid(grabbed.studentMobile)) {
    return grabbed.studentMobile.trim();
  }

  // 3. PRIORITY 3: Check raw map on lead for 'mobile' or 'student_mobile'
  try {
    final m = lead.toMap();
    for (final k in [
      'mobile',
      'student_mobile',
      'student_mobile_no',
      'student_phone',
      'studentMobile',
      'phone',
      'contact',
    ]) {
      final v = m[k]?.toString();
      if (isValid(v)) return v!.trim();
    }
  } catch (_) {}

  return '';
}

Future<void> _makeCall(String phone, BuildContext context) async {
  final clean = phone.replaceAll(RegExp(r'[^\d+]'), '').trim();
  print("📞 [DIALER] Calling lead contact number: $clean (original: $phone)");

  if (clean.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number is not available for this lead.')),
      );
    }
    return;
  }

  final uri = Uri.parse('tel:$clean');
  try {
    bool ok = await launchUrl(uri);
    print("📞 [DIALER] launchUrl standard: $ok");
    if (!ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    print("📞 [DIALER] Error launching $uri: $e");
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e2) {
      print("📞 [DIALER] External launch error: $e2");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer: $clean')),
        );
      }
    }
  }
}

/// Directly unlocks the lead (if needed) and triggers a phone call to the contact number.
Future<void> unlockLeadContact(BuildContext context, TutorLead lead) async {
  print("🚀 [UNLOCK] Button clicked for Lead #${lead.id} (${lead.studentName})");

  final leads = Get.isRegistered<TutorLeadsController>()
      ? Get.find<TutorLeadsController>()
      : Get.put(TutorLeadsController());

  bool isValid(String? s) {
    if (s == null) return false;
    final t = s.trim();
    if (t.isEmpty || t == 'null' || t == '0' || t == '—') return false;
    final digits = t.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 6;
  }

  // 1. Get the exact contact number that was added in the lead!
  final existing = leads.grabbedFor(lead.id);
  String phone = _resolveLeadNumber(lead, existing);
  print("🚀 [UNLOCK] Resolved lead contact number: '$phone'");

  // 2. If phone is not yet present, await grabLead from backend to fetch unmasked number
  if (phone.isEmpty) {
    try {
      final res = await leads.grabLead(lead.id.toString());
      print("🚀 [UNLOCK] grabLead response: $res");
      if (res is Map) {
        final d = res['data'];
        if (d is Map) {
          for (final k in [
            'mobile',
            'student_mobile',
            'student_mobile_no',
            'student_phone',
            'phone',
            'contact',
          ]) {
            final v = d[k]?.toString();
            if (isValid(v)) {
              phone = v!.trim();
              break;
            }
          }
        }
      }
      if (phone.isEmpty) {
        final updated = leads.grabbedFor(lead.id);
        if (updated != null && isValid(updated.studentMobile)) {
          phone = updated.studentMobile.trim();
        }
      }
      if (Get.isRegistered<CoinsController>()) {
        Get.find<CoinsController>().fetchMyCoins();
      }
    } catch (e) {
      print("🚀 [UNLOCK] grabLead error: $e");
    }
  } else {
    // If phone is already available, fire grabLead in background to track without delaying the call
    leads.grabLead(lead.id.toString()).then((res) {
      print("🚀 [UNLOCK] Background grabLead response: $res");
      if (Get.isRegistered<CoinsController>()) {
        Get.find<CoinsController>().fetchMyCoins();
      }
    }).catchError((e) {
      print("🚀 [UNLOCK] Background grabLead error: $e");
    });
  }

  // 3. Fallback to student leads controllers if still empty
  if (phone.isEmpty && Get.isRegistered<LeadController>()) {
    final lCtrl = Get.find<LeadController>();
    final s = lCtrl.studentLeads.firstWhereOrNull(
        (x) => x.id == lead.id || x.id.toString() == lead.id.toString());
    if (s != null && isValid(s.mobile)) {
      phone = s.mobile.trim();
      print("🚀 [UNLOCK] Phone found from LeadController: '$phone'");
    }
  }

  if (phone.isEmpty) {
    final sLead = leads.studentLead.firstWhereOrNull(
        (s) => s.id == lead.id || s.id.toString() == lead.id.toString());
    if (sLead != null && isValid(sLead.mobile)) {
      phone = sLead.mobile.trim();
      print("🚀 [UNLOCK] Phone found from studentLead: '$phone'");
    }
  }

  // 4. CALL THAT EXACT NUMBER IMMEDIATELY!
  if (phone.isNotEmpty) {
    print("🚀 [UNLOCK] Placing call to lead contact: '$phone' now!");
    if (context.mounted) {
      await _makeCall(phone, context);
    }
  } else {
    print("❌ [UNLOCK] No contact number found in lead #${lead.id}!");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact number is not available for Lead #${lead.id}.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

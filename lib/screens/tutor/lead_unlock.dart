import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/screens/tutor/grabbed_lead_details_page.dart';

/// Shows a lead's contact details. If the tutor hasn't grabbed the lead yet,
/// asks them to confirm spending coins first, grabs it, then opens the
/// grabbed-lead page (the server only reveals the full number once grabbed).
Future<void> unlockLeadContact(BuildContext context, TutorLead lead) async {
  final leads = Get.find<TutorLeadsController>();

  final existing = leads.grabbedFor(lead.id);
  if (existing != null) {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => GrabbedLeadDetailsPage(enquiry: existing)));
    return;
  }

  final coins = Get.find<CoinsController>();
  final cost = int.tryParse(lead.coins.trim());
  final balance = coins.myCoins.value?.available.toStringAsFixed(0);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unlock contact?'),
      content: Text(
        '${cost != null && cost > 0 ? 'This uses $cost coins' : 'This uses coins'} '
        'from your wallet to get the student\'s contact details.'
        '${balance != null ? '\n\nYour balance: $balance coins' : ''}',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL')),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('UNLOCK')),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final msg = await leads.grabLead(lead.id.toString());
  if (!context.mounted) return;
  if (msg == null) {
    Get.snackbar('Could not unlock',
        leads.error.value.isNotEmpty ? leads.error.value : 'Please try again.',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }
  coins.fetchMyCoins(); // coins were spent
  Get.snackbar('Unlocked', msg, snackPosition: SnackPosition.BOTTOM);

  final grabbed = leads.grabbedFor(lead.id);
  if (grabbed != null) {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => GrabbedLeadDetailsPage(enquiry: grabbed)));
  }
}

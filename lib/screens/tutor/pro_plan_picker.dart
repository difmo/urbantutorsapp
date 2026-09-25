import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';

/// Lets the tutor choose one of the Pro plans configured on the server
/// (master_data → teacher_pro_subscription) and confirm the coin price.
/// Returns the chosen plan id, or null if cancelled.
Future<int?> pickProPlan(BuildContext context) async {
  final md = Get.find<MasterDataController>();
  if (md.masterData.value == null) await md.fetchMasterData();
  if (!context.mounted) return null;

  final plans = (md.masterData.value?.data.teacherProSubscription ?? const [])
      .where((p) => p.status == 1)
      .toList();
  if (plans.isEmpty) {
    Get.snackbar('Pro Membership', 'No plans are available right now.',
        snackPosition: SnackPosition.BOTTOM);
    return null;
  }

  final plan = await showModalBottomSheet<SubscriptionPlan>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Choose a Pro plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          ...plans.map((p) => ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(p.subscriptionType),
                subtitle: p.description.trim().isEmpty
                    ? null
                    : Text(p.description.trim()),
                trailing: Text('${_price(p.price)} coins',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, p),
              )),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (plan == null || !context.mounted) return null;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Buy ${plan.subscriptionType}?'),
      content: Text(
          '${_price(plan.price)} coins will be deducted from your wallet.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL')),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('BUY')),
      ],
    ),
  );
  return ok == true ? plan.id : null;
}

String _price(String raw) =>
    (double.tryParse(raw) ?? 0).toStringAsFixed(0);

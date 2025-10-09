import 'package:get/get.dart';
import 'package:urbantutorsapp/models/transaction_models.dart';
import 'package:urbantutorsapp/services/transaction_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TransactionController extends GetxController {
  final TransactionService _svc = TransactionService();

  // reactive state
  final isLoading = false.obs;
  final error = ''.obs;
  final items = <TransactionEntry>[].obs;
  final userId = 0.obs;

  double get totalCredit =>
      items.fold(0.0, (sum, e) => sum + (e.credit));
  double get totalDebit =>
      items.fold(0.0, (sum, e) => sum + (e.debit));
  double get net => totalCredit - totalDebit;

  Future<void> bootstrap() async {
    isLoading.value = true;
    error.value = '';
    try {
      final uidStr = await StorageService.getUserId();
      final uid = int.tryParse(uidStr ?? '') ?? 0;
      if (uid <= 0) throw Exception('No user id found');

      userId.value = uid;

      final payload = await _svc.fetchTransactions(uid);
      items.assignAll(payload.items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    try {
      final uid = userId.value;
      if (uid <= 0) return;
      final payload = await _svc.fetchTransactions(uid);
      items.assignAll(payload.items);
    } catch (e) {
      error.value = e.toString();
    }
  }
}

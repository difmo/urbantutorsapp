import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/transaction_models.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class TransactionService {
  /// POST form-data: { user_id }
  Future<TransactionsPayload> fetchTransactions(int userId) async {
    final form = FormData.fromMap({'user_id': userId.toString()});
    final res = await ApiService.post('/transaction_view', form);
    return TransactionsPayload.fromJson(res.data as Map<String, dynamic>);
  }
}

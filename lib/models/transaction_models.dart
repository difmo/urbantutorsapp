class TransactionsPayload {
  final bool success;
  final List<TransactionEntry> items;
  final String message;

  TransactionsPayload({
    required this.success,
    required this.items,
    required this.message,
  });

  factory TransactionsPayload.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List? ?? [])
        .map((e) => TransactionEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return TransactionsPayload(
      success: json['success'] == true,
      items: data,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class TransactionEntry {
  final int id;
  final int userId;
  final String crBalance; // "6000.00"
  final String drBalance; // "150.00"
  final int? grabLeadId;
  final int? studentGetCourseId; // note: api key is "stuentgetcourse_id"
  final int? transactionsId; // key: "trasactions_id"
  final String reason;
  final String createdAt;

  TransactionEntry({
    required this.id,
    required this.userId,
    required this.crBalance,
    required this.drBalance,
    required this.grabLeadId,
    required this.studentGetCourseId,
    required this.transactionsId,
    required this.reason,
    required this.createdAt,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    num(dynamic v) =>
        v == null ? null : (v ? v : num(v).tryParse(v.toString()));
     int(dynamic v) => num(v)?.toInt();

    return TransactionEntry(
      id: int(json['id']) ?? 0,
      userId: int(json['user_id']) ?? 0,
      crBalance: (json['cr_balance'] ?? '0').toString(),
      drBalance: (json['dr_balance'] ?? '0').toString(),
      grabLeadId: int(json['grablead_id']),
      studentGetCourseId: int(json['stuentgetcourse_id']),
      transactionsId: int(json['trasactions_id']),
      reason: (json['reason'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  double get credit => double.tryParse(crBalance) ?? 0.0;
  double get debit  => double.tryParse(drBalance) ?? 0.0;
  bool   get isCredit => credit > 0;
  bool   get isDebit  => debit  > 0;
}

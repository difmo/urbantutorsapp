/// Error thrown by the network layer. [toString] returns only the
/// human-readable message, so `e.toString()` is safe to show in the UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

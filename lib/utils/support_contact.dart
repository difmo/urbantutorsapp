import 'package:url_launcher/url_launcher.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

/// Sends messages to the support team through the user's email app.
class SupportContact {
  static const email = 'support@urbantutors.pro';

  /// Opens the mail composer pre-filled with [subject] and [body], plus the
  /// user's name, phone and id so support can identify them. Returns false
  /// when no email app is available.
  static Future<bool> compose({
    required String subject,
    String body = '',
  }) async {
    final name = await StorageService.getUserName() ?? '';
    final phone = await StorageService.getUserPhoneNumber() ?? '';
    final userId = await StorageService.getUserId() ?? '';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encode({
        'subject': subject,
        'body': '$body\n\n---\nName: $name\nPhone: $phone\nUser ID: $userId',
      }),
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  // Uri(queryParameters:) encodes spaces as '+', which mail apps show
  // literally, so encode with %20 instead.
  static String _encode(Map<String, String> params) => params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

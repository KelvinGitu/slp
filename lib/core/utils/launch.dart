import 'package:flutter/widgets.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the dialler. Shows a calm message if the device can't place calls
/// (a browser without a phone handler, say).
Future<void> callNumber(BuildContext context, String? phone) async {
  if (phone == null || phone.isEmpty) {
    showSnackBar(context, 'No phone number saved.');
    return;
  }
  final ok = await launchUrl(Uri(scheme: 'tel', path: phone));
  if (!ok && context.mounted) showSnackBar(context, "Couldn't start a call. Dial $phone.");
}

/// Opens the SMS app with the number (and an optional message) filled in.
Future<void> messageNumber(BuildContext context, String? phone, {String? body}) async {
  if (phone == null || phone.isEmpty) {
    showSnackBar(context, 'No phone number saved.');
    return;
  }
  final uri = Uri(scheme: 'sms', path: phone, queryParameters: body == null ? null : {'body': body});
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) showSnackBar(context, "Couldn't open messages. Text $phone.");
}

/// Kenyan numbers in the international form wa.me needs: "0712 345 678" and
/// "+254 712 345 678" both become "254712345678". Null if it isn't a number.
String? whatsAppNumber(String? phone) {
  final digits = phone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (digits.isEmpty) return null;
  if (digits.startsWith('0') && digits.length == 10) return '254${digits.substring(1)}';
  if (digits.length == 9 && (digits.startsWith('7') || digits.startsWith('1'))) return '254$digits';
  return digits;
}

/// Opens a WhatsApp chat with [phone], with [text] typed in. Without a
/// number, opens WhatsApp's own contact picker.
Future<void> openWhatsApp(BuildContext context, String? phone, {required String text}) async {
  final number = whatsAppNumber(phone);
  final uri = Uri.https('wa.me', number == null ? '/' : '/$number', {'text': text});
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) showSnackBar(context, "Couldn't open WhatsApp.");
}

/// Opens the mail app with a draft to [email].
Future<void> sendEmail(BuildContext context, String? email, {required String subject, required String body}) async {
  final uri = Uri(scheme: 'mailto', path: email ?? '', query: _encodeQuery({'subject': subject, 'body': body}));
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) showSnackBar(context, "Couldn't open your email app.");
}

// mailto needs %20 for spaces; Uri.queryParameters would write "+".
String _encodeQuery(Map<String, String> params) =>
    params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

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

/// Opens a location in Google Maps (app or browser).
Future<void> openInMaps(double lat, double lng) =>
    launchUrl(Uri.parse('https://maps.google.com/?q=$lat,$lng'), mode: LaunchMode.externalApplication);

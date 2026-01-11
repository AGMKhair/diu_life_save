import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phone) async {
  final Uri uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

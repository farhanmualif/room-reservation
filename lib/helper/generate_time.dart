import 'package:intl/intl.dart';

String generateNow() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyyMMddHHmmss');
  return formatter.format(now);
}

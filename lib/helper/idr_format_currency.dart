import 'package:intl/intl.dart';


final currencyFormatter = NumberFormat.currency(
  locale: 'id_ID', // Indonesian locale
  symbol: 'Rp ', // Indonesian Rupiah symbol
);
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

extension NumX on num {
  String toCurrencyIdr({bool withSymbol = true, int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp ' : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  Widget get gapW => SizedBox(width: toDouble());

  Widget get gapH => SizedBox(height: toDouble());
}

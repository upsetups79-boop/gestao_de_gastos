 import 'package:intl/intl.dart';
                                                                                                                          class CurrencyFormatter {
    static final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');                                   static final _dateFormat = DateFormat('dd/MM/yyyy');
    static final _monthFormat = DateFormat('MMMM yyyy', 'pt_BR');

    static String format(double value) => _currencyFormat.format(value);
    static String formatDate(DateTime date) => _dateFormat.format(date);
    static String formatMonth(DateTime date) => _monthFormat.format(date);
  }
import 'package:intl/intl.dart';

/// Extensions for number formatting
extension NumberFormatExtension on double {
  /// Format as currency with appropriate decimal places
  /// - >= 1000: $43,250.50
  /// - >= 1: $98.25
  /// - < 1: $0.5200
  String formatAsCurrency() {
    if (this >= 1000) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
    } else if (this >= 1) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
    } else {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 4).format(this);
    }
  }

  /// Format as percentage with sign
  /// Examples: +2.50%, -1.20%
  String formatAsPercentage() {
    final format = NumberFormat('+#,##0.00;-#,##0.00');
    return '${format.format(this)}%';
  }

  /// Format as compact number
  /// Examples: 1.2B, 850M, 45K
  String formatCompact() {
    if (this >= 1e12) {
      return '\$${(this / 1e12).toStringAsFixed(2)}T';
    } else if (this >= 1e9) {
      return '\$${(this / 1e9).toStringAsFixed(2)}B';
    } else if (this >= 1e6) {
      return '\$${(this / 1e6).toStringAsFixed(2)}M';
    } else if (this >= 1e3) {
      return '\$${(this / 1e3).toStringAsFixed(2)}K';
    } else {
      return '\$$this';
    }
  }
}

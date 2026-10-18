class FormatUtils {
  static String rupees(double amount) {
    if (amount >= 100000) {
      final v = (amount / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '₹${v}L';
    }
    if (amount >= 1000) {
      final v = (amount / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '₹${v}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String percent(double v) => '${v.toStringAsFixed(1)}%';

  static String kg(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(2)} t' : '${v.toStringAsFixed(0)} kg';
}

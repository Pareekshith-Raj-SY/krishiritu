import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String formatShort(DateTime d) => DateFormat('dd/MM/yy').format(d);
  static String formatMonth(DateTime d) => DateFormat('MMMM yyyy').format(d);

  static String currentSeason() {
    final m = DateTime.now().month;
    if (m >= 6 && m <= 10) return 'Kharif';
    if (m >= 11 || m <= 2) return 'Rabi';
    return 'Summer';
  }

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static DateTime? safeParse(String? s) =>
      s == null ? null : DateTime.tryParse(s);
}

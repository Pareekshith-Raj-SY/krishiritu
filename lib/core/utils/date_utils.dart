import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String formatShort(DateTime d) => DateFormat('dd/MM/yy').format(d);
  static String formatMonth(DateTime d) => DateFormat('MMMM yyyy').format(d);

  static String formatPresentDate(DateTime d, [String langCode = 'en']) {
    const weekdaysEn = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const weekdaysKn = ['', 'ಸೋಮವಾರ', 'ಮಂಗಳವಾರ', 'ಬುಧವಾರ', 'ಗುರುವಾರ', 'ಶುಕ್ರವಾರ', 'ಶನಿವಾರ', 'ಭಾನುವಾರ'];
    const weekdaysHi = ['', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];

    const monthsEn = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const monthsKn = ['', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್'];
    const monthsHi = ['', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

    final day = d.day;
    final year = d.year;

    if (langCode == 'kn') {
      final w = (d.weekday >= 1 && d.weekday <= 7) ? weekdaysKn[d.weekday] : '';
      final m = (d.month >= 1 && d.month <= 12) ? monthsKn[d.month] : '';
      return '$w, $day $m $year';
    } else if (langCode == 'hi') {
      final w = (d.weekday >= 1 && d.weekday <= 7) ? weekdaysHi[d.weekday] : '';
      final m = (d.month >= 1 && d.month <= 12) ? monthsHi[d.month] : '';
      return '$w, $day $m $year';
    } else {
      final w = (d.weekday >= 1 && d.weekday <= 7) ? weekdaysEn[d.weekday] : '';
      final m = (d.month >= 1 && d.month <= 12) ? monthsEn[d.month] : '';
      return '$w, $day $m $year';
    }
  }

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

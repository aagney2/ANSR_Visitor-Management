import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BadgeNumberService {
  static const _keyDate = 'badge_date';
  static const _keyCounter = 'badge_counter';

  /// Returns the next badge number for today, auto-incrementing.
  /// Resets to 1 at the start of each new day.
  static Future<String> getNextBadgeNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final storedDate = prefs.getString(_keyDate);

    int counter;
    if (storedDate == today) {
      counter = (prefs.getInt(_keyCounter) ?? 0) + 1;
    } else {
      counter = 1;
      await prefs.setString(_keyDate, today);
    }

    await prefs.setInt(_keyCounter, counter);
    return counter.toString();
  }

  /// Peeks at what the next badge number would be without incrementing.
  static Future<String> peekNextBadgeNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final storedDate = prefs.getString(_keyDate);

    if (storedDate == today) {
      return ((prefs.getInt(_keyCounter) ?? 0) + 1).toString();
    }
    return '1';
  }
}

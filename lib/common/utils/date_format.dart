const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatIsoDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

String formatJapaneseDate(DateTime date) {
  final weekday = _weekdayLabels[date.weekday - 1];
  return '${date.year}年${date.month}月${date.day}日($weekday)';
}

String formatJapaneseMonth(DateTime date) {
  return '${date.year}年${date.month.toString().padLeft(2, '0')}月';
}

String formatShortJapaneseDate(DateTime date) {
  final weekday = _weekdayLabels[date.weekday - 1];
  return '${date.month}月${date.day}日($weekday)';
}

String formatTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.hour)}:${two(date.minute)}';
}

/// TimeFace2 API が受け付ける日付形式(Y/n/j、ゼロ埋めなし)
String formatSlashDate(DateTime date) {
  return '${date.year}/${date.month}/${date.day}';
}

/// "2026/8/24" 形式の文字列をDateTimeへ変換する
DateTime parseSlashDate(String value) {
  final parts = value.split('/');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

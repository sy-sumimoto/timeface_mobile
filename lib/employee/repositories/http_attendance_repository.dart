import '../../common/api/api_client.dart';
import '../../common/utils/date_format.dart';
import '../models/attendance.dart';
import 'attendance_repository.dart';

/// TimeFace (`GET /api/mobile/attendance/monthly`)を叩く実装。
///
/// レスポンスの `days` は対象月の全暦日ぶんを1本の配列で返す(出勤日・休日の区別は
/// 無く、`hasAttendance` で判定する)ため、ここで出勤日([AttendanceRecord])と
/// 休日([AttendanceRestDay])の2リストに振り分けている。
///
/// 日別の残業・深夜労働・休日出勤・承認状況・備考、および月内に判定不可日を
/// 含むかどうか(`summary.hasUnresolvableDay`)もレスポンスから取り込む。
/// 一方、月次合計の残業時間・遅刻早退件数はAPIから返らないため補足テキストは空にしている。
class HttpAttendanceRepository implements AttendanceRepository {
  HttpAttendanceRepository({required this.client});

  final ApiClient client;

  @override
  Future<AttendanceSummary> fetchSummary(DateTime month) async {
    final data = await client.get('/attendance/monthly?year=${month.year}&month=${month.month}');
    final summary = data['summary'] as Map<String, dynamic>;
    final days = data['days'] as List;

    final records = <AttendanceRecord>[];
    final restDays = <AttendanceRestDay>[];
    for (final e in days) {
      final item = e as Map<String, dynamic>;
      final date = DateTime.parse(item['date'] as String);
      final dateLabel = formatShortJapaneseDate(date);
      if (item['hasAttendance'] as bool) {
        records.add(AttendanceRecord(
          date: dateLabel,
          workType: item['divisionLabel'] as String? ?? '',
          statusLabel: item['statusLabel'] as String? ?? '',
          scheduledTime: item['roundedWorkTimeLabel'] as String? ?? '―',
          actualTime: item['actualWorkTimeLabel'] as String? ?? '―',
          breakTime: item['breakTimeLabel'] as String? ?? '―',
          attendanceId: item['attendanceId'] as int?,
          workedTime: item['workedTimeLabel'] as String? ?? '―',
          overtime: item['overtimeLabel'] as String? ?? '―',
          holidayWork: item['holidayWorkLabel'] as String? ?? '―',
          midnight: item['midnightLabel'] as String? ?? '―',
          midnightIsEstimate: item['midnightIsEstimate'] as bool? ?? false,
          isUnresolvable: item['isUnresolvable'] as bool? ?? false,
          approvalLabel: item['approvalLabel'] as String? ?? '―',
          note: item['extraInfoLabel'] as String? ?? '',
          noteFull: item['extraInfoFull'] as String?,
        ));
      } else {
        restDays.add(AttendanceRestDay(date: dateLabel, label: item['statusLabel'] as String? ?? '休日'));
      }
    }

    return AttendanceSummary(
      month: month,
      workDays: summary['workDaysLabel'] as String,
      absentDays: summary['absentDaysLabel'] as String,
      // 遅刻・早退件数の内訳を返すAPIが無いため未対応のまま
      lateEarlyText: '',
      totalWorkTime: summary['totalWorkTimeLabel'] as String,
      // 月次の残業合計を返すAPIが無いため未対応のまま(日別の残業は各recordに入る)
      overtimeText: '',
      unapprovedCount: summary['unapprovedCountLabel'] as String,
      hasUnresolvableDay: summary['hasUnresolvableDay'] as bool? ?? false,
      records: records,
      restDays: restDays,
    );
  }
}

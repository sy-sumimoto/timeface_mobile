import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/employee/repositories/http_attendance_repository.dart';

/// GET /api/mobile/attendance/monthly のレスポンス項目
/// (残業・休日出勤・深夜労働・承認状況・備考・判定不可日)の取り込みを検証する。

Map<String, dynamic> _day(Map<String, dynamic> overrides) => {
      'date': '2026-09-10',
      'dateLabel': '9/10',
      'dayOfWeekLabel': '木',
      'hasAttendance': true,
      'attendanceId': 1,
      'divisionLabel': '通常勤務',
      'actualWorkTimeLabel': '9:00〜18:00',
      'roundedWorkTimeLabel': '9:00〜18:00',
      'workedTimeLabel': '8時間00分',
      'overtimeLabel': '0時間00分',
      'holidayWorkLabel': '0時間00分',
      'midnightLabel': '0時間00分',
      'midnightIsEstimate': false,
      'isUnresolvable': false,
      'breakTimeLabel': '1時間00分',
      'statusLabel': '出勤',
      'approvalLabel': '―',
      'extraInfoLabel': '',
      'extraInfoFull': null,
      ...overrides,
    };

void main() {
  test('残業・深夜・休日出勤・承認状況・備考を AttendanceRecord に取り込む', () async {
    final api = _FakeApiClient({
      'summary': {
        'workDaysLabel': '2日',
        'absentDaysLabel': '0日',
        'totalWorkTimeLabel': '17時間30分',
        'unapprovedCountLabel': '1件',
        'hasUnresolvableDay': true,
      },
      'days': [
        _day({
          'date': '2026-09-10',
          'attendanceId': 10,
          'overtimeLabel': '1時間30分',
          'midnightLabel': '0時間00分',
          'approvalLabel': '承認済み',
        }),
        _day({
          'date': '2026-09-11',
          'attendanceId': 11,
          'overtimeLabel': '判定不可',
          'holidayWorkLabel': '判定不可',
          'midnightLabel': '1時間00分',
          'midnightIsEstimate': true,
          'isUnresolvable': true,
          'approvalLabel': '申請中',
          'extraInfoLabel': '直行',
          'extraInfoFull': '直行のため事業所到着は10時',
        }),
        _day({
          'date': '2026-09-12',
          'hasAttendance': false,
          'attendanceId': null,
          'statusLabel': '所定休日',
        }),
      ],
    });
    final repo = HttpAttendanceRepository(client: api);

    final summary = await repo.fetchSummary(DateTime(2026, 9));

    expect(api.lastPath, '/attendance/monthly?year=2026&month=9');
    expect(summary.hasUnresolvableDay, isTrue);
    expect(summary.records, hasLength(2));
    expect(summary.restDays, hasLength(1));
    expect(summary.restDays.single.label, '所定休日');

    final normal = summary.records[0];
    expect(normal.attendanceId, 10);
    expect(normal.overtime, '1時間30分');
    expect(normal.holidayWork, '0時間00分');
    expect(normal.midnight, '0時間00分');
    expect(normal.midnightIsEstimate, isFalse);
    expect(normal.isUnresolvable, isFalse);
    expect(normal.approvalLabel, '承認済み');
    expect(normal.note, '');
    expect(normal.noteFull, isNull);

    final unresolvable = summary.records[1];
    expect(unresolvable.overtime, '判定不可');
    expect(unresolvable.holidayWork, '判定不可');
    expect(unresolvable.midnight, '1時間00分');
    expect(unresolvable.midnightIsEstimate, isTrue);
    expect(unresolvable.isUnresolvable, isTrue);
    expect(unresolvable.approvalLabel, '申請中');
    expect(unresolvable.note, '直行');
    expect(unresolvable.noteFull, '直行のため事業所到着は10時');
    expect(unresolvable.workedTime, '8時間00分');
  });

  test('summary.hasUnresolvableDay と日別の任意項目が欠けていても既定値で読める', () async {
    final api = _FakeApiClient({
      'summary': {
        'workDaysLabel': '1日',
        'absentDaysLabel': '0日',
        'totalWorkTimeLabel': '8時間00分',
        'unapprovedCountLabel': '0件',
        // hasUnresolvableDay を返さない旧レスポンス相当
      },
      'days': [
        {
          'date': '2026-09-10',
          'hasAttendance': true,
          'divisionLabel': '通常勤務',
          'actualWorkTimeLabel': '9:00〜18:00',
          'roundedWorkTimeLabel': '9:00〜18:00',
          'breakTimeLabel': '1時間00分',
          'statusLabel': '出勤',
          // overtimeLabel / midnightLabel / isUnresolvable / approvalLabel / extraInfo なし
        },
      ],
    });
    final repo = HttpAttendanceRepository(client: api);

    final summary = await repo.fetchSummary(DateTime(2026, 9));

    expect(summary.hasUnresolvableDay, isFalse);
    final r = summary.records.single;
    expect(r.overtime, '―');
    expect(r.holidayWork, '―');
    expect(r.midnight, '―');
    expect(r.midnightIsEstimate, isFalse);
    expect(r.isUnresolvable, isFalse);
    expect(r.approvalLabel, '―');
    expect(r.note, '');
    expect(r.noteFull, isNull);
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.response) : super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, dynamic> response;
  String? lastPath;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    lastPath = path;
    return response;
  }
}

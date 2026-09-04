import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/widgets/attendance_card.dart';

Future<void> _pump(WidgetTester tester, AttendanceCard card) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: card))),
  );
}

void main() {
  testWidgets('残業・深夜・承認状況・備考を表示する', (tester) async {
    await _pump(
      tester,
      const AttendanceCard(
        date: '9月10日(木)',
        workType: '通常勤務',
        statusLabel: '出勤',
        scheduledTime: '9:00〜19:30',
        actualTime: '8:59〜19:35',
        breakTime: '1時間00分',
        workedTime: '9時間36分',
        overtime: '1時間36分',
        holidayWork: '0時間00分',
        midnight: '1時間00分',
        midnightIsEstimate: true,
        approvalLabel: '申請中',
        note: '直行',
      ),
    );

    expect(find.text('実働 9時間36分'), findsOneWidget);
    expect(find.text('残業 1時間36分'), findsOneWidget);
    expect(find.text('深夜 1時間00分（概算）'), findsOneWidget);
    expect(find.text('申請中'), findsOneWidget); // 承認状況バッジ
    expect(find.text('備考: 直行'), findsOneWidget);
  });

  testWidgets('判定不可の日は注意書きを表示する', (tester) async {
    await _pump(
      tester,
      const AttendanceCard(
        date: '9月11日(金)',
        workType: '通常勤務',
        statusLabel: '出勤',
        scheduledTime: '9:00〜19:30',
        actualTime: '8:57〜19:33',
        breakTime: '1時間00分',
        overtime: '判定不可',
        holidayWork: '判定不可',
        isUnresolvable: true,
      ),
    );

    expect(find.text('残業 判定不可'), findsOneWidget);
    expect(
      find.text('勤務パターン未設定のため、残業・休日出勤を判定できません'),
      findsOneWidget,
    );
  });

  testWidgets('値が "―" の項目は表示しない', (tester) async {
    await _pump(
      tester,
      const AttendanceCard(
        date: '9月12日(土)',
        workType: '通常勤務',
        statusLabel: '出勤',
        scheduledTime: '9:00〜18:00',
        actualTime: '9:00〜18:00',
        breakTime: '1時間00分',
        // workedTime/overtime/holidayWork/midnight/approvalLabel は既定の "―"
      ),
    );

    expect(find.textContaining('実働'), findsNothing);
    expect(find.textContaining('残業'), findsNothing);
    expect(find.textContaining('深夜'), findsNothing);
    expect(find.text('―'), findsNothing); // 承認バッジも出ない
    expect(find.textContaining('備考'), findsNothing);
  });
}

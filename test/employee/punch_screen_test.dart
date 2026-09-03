import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/models/punch_state.dart';
import 'package:timeface_mobile/employee/screens/punch_screen.dart';

/// 単体テスト仕様書(ユーザー_打刻画面) の「初期表示」系のうち、Widgetテストで自動化できるケース。

PunchState _state({
  String location = '本社オフィス',
  String employeeName = '中村陽子',
  String statusLabel = '未出勤',
  bool canClockIn = false,
  bool canClockOut = false,
  bool canStartBreak = false,
  bool canEndBreak = false,
}) {
  return PunchState(
    location: location,
    employeeName: employeeName,
    statusLabel: statusLabel,
    clockInTime: null,
    canClockIn: canClockIn,
    canClockOut: canClockOut,
    canStartBreak: canStartBreak,
    canEndBreak: canEndBreak,
  );
}

Future<void> _pump(
  WidgetTester tester,
  PunchState? state, {
  VoidCallback? onClockIn,
  VoidCallback? onClockOut,
  VoidCallback? onBreakStart,
  VoidCallback? onBreakEnd,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PunchScreen(
          punchState: state,
          onClockIn: onClockIn ?? () {},
          onClockOut: onClockOut ?? () {},
          onBreakStart: onBreakStart ?? () {},
          onBreakEnd: onBreakEnd ?? () {},
        ),
      ),
    ),
  );
}

bool _enabled(WidgetTester tester, String label) {
  final button = tester.widget<ElevatedButton>(
    find.ancestor(of: find.text(label), matching: find.byType(ElevatedButton)),
  );
  return button.enabled;
}

void main() {
  testWidgets('[No.1] レイアウト: 4つの打刻ボタンと事業所名・氏名が表示される', (tester) async {
    await _pump(tester, _state(canClockIn: true));

    expect(find.text('出勤'), findsOneWidget);
    expect(find.text('退勤'), findsOneWidget);
    expect(find.text('休憩開始'), findsOneWidget);
    expect(find.text('休憩終了'), findsOneWidget);
    expect(find.text('本社オフィス'), findsOneWidget);
    expect(find.text('中村陽子'), findsOneWidget);
  });

  testWidgets('[No.4] 事業所名は固定文言「本社オフィス」が表示される', (tester) async {
    await _pump(tester, _state(location: '本社オフィス', canClockIn: true));
    expect(find.text('本社オフィス'), findsOneWidget);
  });

  testWidgets('[No.5] ログイン中の従業員氏名が表示される', (tester) async {
    await _pump(tester, _state(employeeName: '山田太郎', canClockIn: true));
    expect(find.text('山田太郎'), findsOneWidget);
  });

  testWidgets('[No.6] ボタン活性(未出勤): 出勤のみ活性', (tester) async {
    await _pump(tester, _state(statusLabel: '未出勤', canClockIn: true));

    expect(_enabled(tester, '出勤'), isTrue);
    expect(_enabled(tester, '退勤'), isFalse);
    expect(_enabled(tester, '休憩開始'), isFalse);
    expect(_enabled(tester, '休憩終了'), isFalse);
  });

  testWidgets('[No.7] ボタン活性(出勤中): 退勤・休憩開始が活性', (tester) async {
    await _pump(
      tester,
      _state(statusLabel: '出勤中', canClockOut: true, canStartBreak: true),
    );

    expect(_enabled(tester, '出勤'), isFalse);
    expect(_enabled(tester, '退勤'), isTrue);
    expect(_enabled(tester, '休憩開始'), isTrue);
    expect(_enabled(tester, '休憩終了'), isFalse);
  });

  testWidgets('[No.8] ボタン活性(休憩中): 休憩終了のみ活性', (tester) async {
    await _pump(tester, _state(statusLabel: '休憩中', canEndBreak: true));

    expect(_enabled(tester, '出勤'), isFalse);
    expect(_enabled(tester, '退勤'), isFalse);
    expect(_enabled(tester, '休憩開始'), isFalse);
    expect(_enabled(tester, '休憩終了'), isTrue);
  });

  testWidgets('活性状態の「出勤」ボタン押下で onClockIn が呼ばれる', (tester) async {
    var tapped = 0;
    await _pump(tester, _state(canClockIn: true), onClockIn: () => tapped++);

    await tester.tap(find.text('出勤'));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('非活性の「退勤」ボタンは押下しても onClockOut が呼ばれない', (tester) async {
    var tapped = 0;
    await _pump(tester, _state(canClockIn: true), onClockOut: () => tapped++);

    await tester.tap(find.text('退勤'), warnIfMissed: false);
    await tester.pump();

    expect(tapped, 0);
  });

  testWidgets('punchState が null の間は全ボタンが非活性', (tester) async {
    await _pump(tester, null);

    expect(_enabled(tester, '出勤'), isFalse);
    expect(_enabled(tester, '退勤'), isFalse);
    expect(_enabled(tester, '休憩開始'), isFalse);
    expect(_enabled(tester, '休憩終了'), isFalse);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/models/paid_holiday.dart';
import 'package:timeface_mobile/employee/repositories/paid_holiday_repository.dart';
import 'package:timeface_mobile/employee/screens/paid_holidays_screen.dart';

/// 失効間近アラート・前期/今期内訳の表示条件を検証する。

class _FakePaidHolidayRepository implements PaidHolidayRepository {
  _FakePaidHolidayRepository(this.summary);

  final PaidHolidaySummary summary;

  @override
  Future<PaidHolidaySummary> fetchSummary() async => summary;

  @override
  Future<PaidHolidayRequestLists> fetchRequests() async =>
      (pending: const <PaidHolidayRequest>[], processed: const <PaidHolidayRequest>[]);

  @override
  Future<String> calculateEndDate({
    required DateTime startDate,
    required PaidHolidayType type,
    required double usedDays,
  }) async =>
      '2026/1/1';

  @override
  Future<PaidHolidayRequest> submitCreate({
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  }) =>
      throw UnimplementedError();

  @override
  Future<PaidHolidayRequest> submitEdit({
    required String id,
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  }) =>
      throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, PaidHolidaySummary summary) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PaidHolidaysScreen(repository: _FakePaidHolidayRepository(summary)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hasExpiringSoon のとき失効間近アラートを表示する', (tester) async {
    await _pump(
      tester,
      const PaidHolidaySummary(
        remainingDays: '8.5日',
        plannedDays: '-',
        nextGrantDate: '2027-01-15',
        previousPeriodDays: '3日',
        currentPeriodDays: '5.5日',
        hasExpiringSoon: true,
        expiringSoonDays: '3日',
        expiringSoonDate: '2026/9/30',
      ),
    );

    expect(find.text('有給休暇 3日 が 2026/9/30 に失効します'), findsOneWidget);
    expect(find.text('内訳  前期 3日  ・  今期 5.5日'), findsOneWidget);
  });

  testWidgets('hasExpiringSoon が false ならアラートを出さない', (tester) async {
    await _pump(
      tester,
      const PaidHolidaySummary(
        remainingDays: '10日',
        plannedDays: '-',
        nextGrantDate: '未定',
        currentPeriodDays: '10日',
      ),
    );

    expect(find.textContaining('失効します'), findsNothing);
    expect(find.textContaining('失効する有給休暇'), findsNothing);
    // 今期のみでも内訳行は出る(前期は「—」)
    expect(find.text('内訳  前期 —  ・  今期 10日'), findsOneWidget);
  });

  testWidgets('前期・今期がどちらも null なら内訳行を出さない', (tester) async {
    await _pump(
      tester,
      const PaidHolidaySummary(
        remainingDays: '10日',
        plannedDays: '-',
        nextGrantDate: '未定',
      ),
    );

    expect(find.textContaining('内訳'), findsNothing);
  });
}

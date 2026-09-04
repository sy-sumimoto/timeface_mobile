import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/models/paid_holiday.dart';
import 'package:timeface_mobile/employee/repositories/paid_holiday_repository.dart';
import 'package:timeface_mobile/employee/screens/paid_holidays_screen.dart';

/// 失効間近アラート・前期/今期内訳の表示条件、および申請取り下げ操作を検証する。

class _FakePaidHolidayRepository implements PaidHolidayRepository {
  _FakePaidHolidayRepository(
    this.summary, {
    this.pending = const [],
    this.processed = const [],
  });

  final PaidHolidaySummary summary;
  List<PaidHolidayRequest> pending;
  List<PaidHolidayRequest> processed;

  final List<String> withdrawnIds = [];

  @override
  Future<PaidHolidaySummary> fetchSummary() async => summary;

  @override
  Future<PaidHolidayRequestLists> fetchRequests() async =>
      (pending: pending, processed: processed);

  @override
  Future<void> withdrawRequest(String id) async {
    withdrawnIds.add(id);
    pending = pending.where((e) => e.id != id).toList();
    processed = processed.where((e) => e.id != id).toList();
  }

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

PaidHolidayRequest _req({
  required String id,
  required PaidHolidayStatus status,
  DateTime? startDate,
}) {
  final start = startDate ?? DateTime(2026, 9, 20);
  return PaidHolidayRequest(
    id: id,
    startDate: start,
    endDate: start,
    type: PaidHolidayType.fullDay,
    usedDays: 1,
    status: status,
    appliedDate: '2026-09-04',
  );
}

const _summary = PaidHolidaySummary(
  remainingDays: '10日',
  plannedDays: '-',
  nextGrantDate: '未定',
);

Future<_FakePaidHolidayRepository> _pump(
  WidgetTester tester, {
  PaidHolidaySummary summary = _summary,
  List<PaidHolidayRequest> pending = const [],
  List<PaidHolidayRequest> processed = const [],
}) async {
  final repo = _FakePaidHolidayRepository(
    summary,
    pending: pending,
    processed: processed,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: PaidHolidaysScreen(repository: repo)),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('失効間近アラート・内訳', () {
    testWidgets('hasExpiringSoon のとき失効間近アラートを表示する', (tester) async {
      await _pump(
        tester,
        summary: const PaidHolidaySummary(
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
        summary: const PaidHolidaySummary(
          remainingDays: '10日',
          plannedDays: '-',
          nextGrantDate: '未定',
          currentPeriodDays: '10日',
        ),
      );

      expect(find.textContaining('失効します'), findsNothing);
      expect(find.text('内訳  前期 —  ・  今期 10日'), findsOneWidget);
    });

    testWidgets('前期・今期がどちらも null なら内訳行を出さない', (tester) async {
      await _pump(tester);
      expect(find.textContaining('内訳'), findsNothing);
    });
  });

  group('申請の取り下げ', () {
    testWidgets('承認待ちの申請に「取り下げ」ボタンが出る', (tester) async {
      await _pump(
        tester,
        pending: [_req(id: '10', status: PaidHolidayStatus.pending)],
      );
      expect(find.widgetWithText(OutlinedButton, '取り下げ'), findsOneWidget);
    });

    testWidgets('「取り下げ」→確認ダイアログ→取り下げるで withdrawRequest が呼ばれ一覧が更新される',
        (tester) async {
      final repo = await _pump(
        tester,
        pending: [_req(id: '10', status: PaidHolidayStatus.pending)],
      );

      await tester.tap(find.widgetWithText(OutlinedButton, '取り下げ'));
      await tester.pumpAndSettle();
      // 確認ダイアログ
      expect(find.text('申請の取り下げ'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, '取り下げる'));
      await tester.pumpAndSettle();

      expect(repo.withdrawnIds, ['10']);
      expect(find.text('有給休暇申請を取り下げました'), findsOneWidget); // SnackBar
      // 再取得され、リストから消えている
      expect(find.widgetWithText(OutlinedButton, '取り下げ'), findsNothing);
    });

    testWidgets('確認ダイアログでキャンセルすると withdrawRequest は呼ばれない', (tester) async {
      final repo = await _pump(
        tester,
        pending: [_req(id: '10', status: PaidHolidayStatus.pending)],
      );

      await tester.tap(find.widgetWithText(OutlinedButton, '取り下げ'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'キャンセル'));
      await tester.pumpAndSettle();

      expect(repo.withdrawnIds, isEmpty);
    });

    testWidgets('処理済みタブ: 承認済みで開始日が未来なら取り下げ可、過去なら不可', (tester) async {
      await _pump(
        tester,
        processed: [
          _req(
            id: 'future',
            status: PaidHolidayStatus.approved,
            startDate: DateTime.now().add(const Duration(days: 7)),
          ),
          _req(
            id: 'past',
            status: PaidHolidayStatus.approved,
            startDate: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      );

      await tester.tap(find.text('処理済み'));
      await tester.pumpAndSettle();

      // 未来ぶん1件だけ「取り下げ」ボタンが出る
      expect(find.widgetWithText(OutlinedButton, '取り下げ'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/widgets/app_bottom_nav.dart';

/// 下部タブの未読バッジ表示を検証する。

Future<void> _pump(WidgetTester tester, int badgeCount) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          currentIndex: 0,
          items: [
            const AppBottomNavItem(icon: Icons.home_rounded, label: 'ホーム'),
            AppBottomNavItem(
              icon: Icons.mail_rounded,
              label: 'お知らせ',
              badgeCount: badgeCount,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('badgeCount が 0 のときバッジを出さない', (tester) async {
    await _pump(tester, 0);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('badgeCount が 1〜9 のときはその数字を出す', (tester) async {
    await _pump(tester, 3);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('badgeCount が 10 以上のときは 9+ を出す', (tester) async {
    await _pump(tester, 15);
    expect(find.text('9+'), findsOneWidget);
    expect(find.text('15'), findsNothing);
  });
}

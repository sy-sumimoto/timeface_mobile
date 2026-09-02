import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timeface_mobile/main.dart';

void main() {
  testWidgets('Login screen shows the TimeFace sign-in form', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('企業管理者ログイン'), findsOneWidget);
    expect(find.text('ログイン'), findsOneWidget);
  });

  testWidgets('Login without input shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('ログイン'));
    await tester.pump();

    expect(find.text('メールアドレスを入力してください'), findsOneWidget);
    expect(find.text('パスワードを入力してください'), findsOneWidget);
  });
}

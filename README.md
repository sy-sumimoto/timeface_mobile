# timeface_mobile

TimeFace2(Laravel/Sanctum)のモバイル向けAPI(`/api/mobile/*`)を叩く、勤怠管理サービス「TimeFace」の従業員向けFlutterアプリ。
出勤/退勤/休憩の打刻、勤怠照会、有給休暇の申請、お知らせ確認などができる。

## 前提環境

- Flutter **3.47.0**（stable channel, revision `4cf2416426`）／Dart 3.13.0
  - `.metadata` に記録されているバージョンと合わせること。`flutter --version` で確認できる。
  - 異なるバージョンでも動く可能性はあるが、未検証。
- Android実機/エミュレータ向け: Android Studio（Android SDK・Java(JBR)同梱）
- iOS実機/シミュレータ向け（macOSのみ）: Xcode
- **Windowsで開発する場合**: 「開発者モード」を有効化しておくこと（プラグイン解決にシンボリックリンクを使うため）。
  未設定だと `flutter pub get` / `flutter build` が `Building with plugins requires symlink support.` で失敗する。
  設定 → プライバシーとセキュリティ → 開発者向け、または `start ms-settings:developers` から有効化。

## セットアップ

```powershell
flutter pub get
```

## 実行方法(API接続先)

APIの接続先は `--dart-define=API_ORIGIN=...` で切り替える。**未指定時は本番のTimeFace2 (`https://timeface.ddd-system.co.jp`) に接続する。**

ローカルのTimeFace2(`php artisan serve --port=8123`)に接続してテストする場合は、環境に応じて以下を指定する。

| 実行環境 | 指定するAPI_ORIGIN |
|---|---|
| Androidエミュレータ | `http://10.0.2.2:8123`(エミュレータからホストPCを指すエイリアス) |
| iOSシミュレータ / デスクトップ(Windows/macOS) | `http://127.0.0.1:8123` |
| 実機(Android/iOS) | `http://<ホストPCのLAN IP>:8123`(実機とホストPCが同じネットワークにいること) |

```powershell
# 例: Androidエミュレータでローカルサーバーに接続して起動
flutter run -d <device-id> --dart-define=API_ORIGIN=http://10.0.2.2:8123
```

本番サーバーに接続する場合は `--dart-define` を付けずにそのまま実行すればよい。

```powershell
flutter run -d <device-id>
```

## テスト・静的解析

```powershell
flutter analyze
flutter test
```

`test/widget_test.dart` の2件（`企業管理者ログイン`関連）は、アプリの起動フローが従業員ログインに変更された後もテスト側が更新されておらず**既知の失敗**。実装のバグではないので、直す際はテスト側の期待値をログイン画面の実際の表示内容に合わせて修正すること。

## プロジェクト構成

```
lib/
  common/     共通のAPIクライアント・ウィジェット・ユーティリティ(従業員/企業双方で使用)
  employee/   従業員向け画面(ログイン・打刻・勤怠照会・有給休暇・お知らせ)。main.dartはここに直接起動する
  company/    企業管理者向け画面(ログイン・従業員/部署/事業所管理など)。
              実装は存在するが、ロール選択画面が未実装のため現状アプリからは到達不可
  admin/      未着手
```

## アプリアイコンの変更

`assets/icon/icon.png`(通常アイコン)・`assets/icon/icon_foreground.png`(Androidアダプティブアイコンのフォアグラウンド、透過)を差し替えた後、以下を実行すると各プラットフォームのアイコンを再生成できる。

```powershell
flutter pub get
dart run flutter_launcher_icons
```

設定は `pubspec.yaml` の `flutter_launcher_icons:` セクション。

## 既知の未整備・制限事項

引き渡し・本番配布前に対応が必要な点。

- **パスワード再設定機能が未接続**: 画面(忘れた方/コード確認/再設定)は実装済みだが、`MockPasswordResetRepository`のままで実APIには繋がっていない([lib/employee/repositories/password_reset_repository.dart](lib/employee/repositories/password_reset_repository.dart))。TimeFace2側に対応APIができ次第、実装を差し替える想定。
- **企業/管理者向けUIが未到達**: `lib/company/`は実装済みだが、ロール選択画面が無いため現在のアプリからは開けない。
- **Android**: `applicationId`が `com.example.timeface_mobile` のまま（[android/app/build.gradle.kts](android/app/build.gradle.kts)）。Google Playに公開するには固有のIDへ変更が必要。またreleaseビルドはdebug鍵で署名される設定になっているため、本番配布用の署名設定(keystore)を別途用意して差し替える必要がある。
- **iOS**: Bundle IDが `com.example.timefaceMobile` のまま、Development Teamも未設定。App Store配布にはApple Developerアカウントでの署名設定が必要。
- 上記の署名設定・アプリID・Apple Developerアカウントは本リポジトリには含まれないため、配布前に必ず用意すること。

## 参考資料

- API仕様: `time_face_スマホアプリAPI仕様書(従業員向け).xlsx`(コード内コメントで参照。リポジトリ外で管理)

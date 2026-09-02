// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリ全体で共有するセキュアストレージのサービス層。
///
/// [FlutterSecureStorage]の生APIを直接公開せず、setValue/getValue等の
/// メソッド越しに操作させることで、キー命名の一元管理や
/// 実装差し替え(暗号化方式の変更・テスト用モック等)をしやすくする。
///
/// 各ロール(従業員/企業管理者/システム管理者)の認証状態Notifierは、
/// ここを経由してアクセストークン等を読み書きする想定。
///
/// TODO: 保存するキーの命名規則(例: `employee_token` / `company_token`)は
/// 実装時にここか呼び出し側で決める。

@ProviderFor(FlutterSecureStorageController)
final flutterSecureStorageControllerProvider =
    FlutterSecureStorageControllerProvider._();

/// アプリ全体で共有するセキュアストレージのサービス層。
///
/// [FlutterSecureStorage]の生APIを直接公開せず、setValue/getValue等の
/// メソッド越しに操作させることで、キー命名の一元管理や
/// 実装差し替え(暗号化方式の変更・テスト用モック等)をしやすくする。
///
/// 各ロール(従業員/企業管理者/システム管理者)の認証状態Notifierは、
/// ここを経由してアクセストークン等を読み書きする想定。
///
/// TODO: 保存するキーの命名規則(例: `employee_token` / `company_token`)は
/// 実装時にここか呼び出し側で決める。
final class FlutterSecureStorageControllerProvider
    extends $NotifierProvider<FlutterSecureStorageController, void> {
  /// アプリ全体で共有するセキュアストレージのサービス層。
  ///
  /// [FlutterSecureStorage]の生APIを直接公開せず、setValue/getValue等の
  /// メソッド越しに操作させることで、キー命名の一元管理や
  /// 実装差し替え(暗号化方式の変更・テスト用モック等)をしやすくする。
  ///
  /// 各ロール(従業員/企業管理者/システム管理者)の認証状態Notifierは、
  /// ここを経由してアクセストークン等を読み書きする想定。
  ///
  /// TODO: 保存するキーの命名規則(例: `employee_token` / `company_token`)は
  /// 実装時にここか呼び出し側で決める。
  FlutterSecureStorageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flutterSecureStorageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flutterSecureStorageControllerHash();

  @$internal
  @override
  FlutterSecureStorageController create() => FlutterSecureStorageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$flutterSecureStorageControllerHash() =>
    r'b28c269921cf170e728d8945ba2043de7608639d';

/// アプリ全体で共有するセキュアストレージのサービス層。
///
/// [FlutterSecureStorage]の生APIを直接公開せず、setValue/getValue等の
/// メソッド越しに操作させることで、キー命名の一元管理や
/// 実装差し替え(暗号化方式の変更・テスト用モック等)をしやすくする。
///
/// 各ロール(従業員/企業管理者/システム管理者)の認証状態Notifierは、
/// ここを経由してアクセストークン等を読み書きする想定。
///
/// TODO: 保存するキーの命名規則(例: `employee_token` / `company_token`)は
/// 実装時にここか呼び出し側で決める。

abstract class _$FlutterSecureStorageController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

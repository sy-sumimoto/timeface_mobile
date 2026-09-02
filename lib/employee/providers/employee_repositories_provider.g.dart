// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_repositories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 従業員側画面に渡す [EmployeeRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(employeeRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: 認証状態(authStateProvider等)からトークンを受け取って
/// ApiClientに渡す、apiBaseUrlを環境ごとに切り替える、などは
/// ここで実装する。

@ProviderFor(employeeRepositories)
final employeeRepositoriesProvider = EmployeeRepositoriesProvider._();

/// 従業員側画面に渡す [EmployeeRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(employeeRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: 認証状態(authStateProvider等)からトークンを受け取って
/// ApiClientに渡す、apiBaseUrlを環境ごとに切り替える、などは
/// ここで実装する。

final class EmployeeRepositoriesProvider
    extends
        $FunctionalProvider<
          EmployeeRepositories,
          EmployeeRepositories,
          EmployeeRepositories
        >
    with $Provider<EmployeeRepositories> {
  /// 従業員側画面に渡す [EmployeeRepositories] を提供するProvider。
  ///
  /// これまでは画面のコンストラクタでバケツリレーしていたが、
  /// `ref.watch(employeeRepositoriesProvider)` で好きな場所から参照できるようにする。
  ///
  /// TODO: 認証状態(authStateProvider等)からトークンを受け取って
  /// ApiClientに渡す、apiBaseUrlを環境ごとに切り替える、などは
  /// ここで実装する。
  EmployeeRepositoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employeeRepositoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employeeRepositoriesHash();

  @$internal
  @override
  $ProviderElement<EmployeeRepositories> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployeeRepositories create(Ref ref) {
    return employeeRepositories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployeeRepositories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployeeRepositories>(value),
    );
  }
}

String _$employeeRepositoriesHash() =>
    r'1b003fb8b9ebf7b00ecc142062a096b807c865d7';

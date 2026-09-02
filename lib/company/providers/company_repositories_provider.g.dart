// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_repositories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 企業管理者側画面に渡す [CompanyRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(companyRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: Mock実装から実APIへの差し替え、認証状態との連携は
/// ここで実装する。

@ProviderFor(companyRepositories)
final companyRepositoriesProvider = CompanyRepositoriesProvider._();

/// 企業管理者側画面に渡す [CompanyRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(companyRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: Mock実装から実APIへの差し替え、認証状態との連携は
/// ここで実装する。

final class CompanyRepositoriesProvider
    extends
        $FunctionalProvider<
          CompanyRepositories,
          CompanyRepositories,
          CompanyRepositories
        >
    with $Provider<CompanyRepositories> {
  /// 企業管理者側画面に渡す [CompanyRepositories] を提供するProvider。
  ///
  /// これまでは画面のコンストラクタでバケツリレーしていたが、
  /// `ref.watch(companyRepositoriesProvider)` で好きな場所から参照できるようにする。
  ///
  /// TODO: Mock実装から実APIへの差し替え、認証状態との連携は
  /// ここで実装する。
  CompanyRepositoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companyRepositoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companyRepositoriesHash();

  @$internal
  @override
  $ProviderElement<CompanyRepositories> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompanyRepositories create(Ref ref) {
    return companyRepositories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanyRepositories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanyRepositories>(value),
    );
  }
}

String _$companyRepositoriesHash() =>
    r'816b5c23573663c4d0314b7fb2b96e317e96605a';

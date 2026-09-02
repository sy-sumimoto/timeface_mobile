import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/company_repositories.dart';

part 'company_repositories_provider.g.dart';

/// 企業管理者側画面に渡す [CompanyRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(companyRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: Mock実装から実APIへの差し替え、認証状態との連携は
/// ここで実装する。
@riverpod
CompanyRepositories companyRepositories(Ref ref) {
  return CompanyRepositories();
}

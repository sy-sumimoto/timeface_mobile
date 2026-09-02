import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/employee_repositories.dart';

part 'employee_repositories_provider.g.dart';

/// 従業員側画面に渡す [EmployeeRepositories] を提供するProvider。
///
/// これまでは画面のコンストラクタでバケツリレーしていたが、
/// `ref.watch(employeeRepositoriesProvider)` で好きな場所から参照できるようにする。
///
/// TODO: 認証状態(authStateProvider等)からトークンを受け取って
/// ApiClientに渡す、apiBaseUrlを環境ごとに切り替える、などは
/// ここで実装する。
@riverpod
EmployeeRepositories employeeRepositories(Ref ref) {
  return EmployeeRepositories();
}

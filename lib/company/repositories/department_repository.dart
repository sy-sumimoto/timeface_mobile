import '../models/department.dart';

/// 部署管理の取得口。TimeFace2の`Company\DepartmentController`に対応する。
/// 事業所選択肢は呼び出し側([OfficeRepository]経由)で取得し、officeId/officeNameを
/// セットで渡す(TimeFace2側の`departments.options`Ajaxに相当する処理は
/// 事業所一覧をそのまま使い回せるため、専用エンドポイントは設けていない)。
abstract class DepartmentRepository {
  Future<List<Department>> fetchAll();

  Future<Department> save({String? id, required String name, required String officeId, required String officeName});

  Future<void> delete(String id);
}

class MockDepartmentRepository implements DepartmentRepository {
  int _nextId = 3;

  final List<Department> _items = [
    const Department(id: 'd1', name: '総務部', officeId: 'o1', officeName: '本社オフィス'),
    const Department(id: 'd2', name: '営業部', officeId: 'o1', officeName: '本社オフィス'),
  ];

  @override
  Future<List<Department>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  @override
  Future<Department> save({String? id, required String name, required String officeId, required String officeName}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (id == null) {
      final created = Department(id: 'd${_nextId++}', name: name, officeId: officeId, officeName: officeName);
      _items.insert(0, created);
      return created;
    }
    final index = _items.indexWhere((e) => e.id == id);
    final updated = _items[index].copyWith(name: name, officeId: officeId, officeName: officeName);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((e) => e.id == id);
  }
}

import '../models/office.dart';

/// 事業所管理の取得口。TimeFace2の`Company\OfficeController`に対応する。
abstract class OfficeRepository {
  Future<List<Office>> fetchAll();

  Future<Office> save({String? id, required String name, required String address, String? tel});

  Future<void> delete(String id);
}

class MockOfficeRepository implements OfficeRepository {
  int _nextId = 3;

  final List<Office> _items = [
    const Office(id: 'o1', name: '本社オフィス', address: '東京都千代田区1-1-1', tel: '03-1234-5678'),
    const Office(id: 'o2', name: '大阪支店', address: '大阪府大阪市北区2-2-2', tel: '06-1234-5678'),
  ];

  @override
  Future<List<Office>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  @override
  Future<Office> save({String? id, required String name, required String address, String? tel}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (id == null) {
      final created = Office(id: 'o${_nextId++}', name: name, address: address, tel: tel);
      _items.insert(0, created);
      return created;
    }
    final index = _items.indexWhere((e) => e.id == id);
    final updated = _items[index].copyWith(name: name, address: address, tel: tel);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((e) => e.id == id);
  }
}

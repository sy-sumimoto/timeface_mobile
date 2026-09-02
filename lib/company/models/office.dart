/// 事業所1件分。TimeFace2の`Office`モデル(`app/Models/Office.php`)に対応する。
class Office {
  const Office({required this.id, required this.name, required this.address, this.tel});

  final String id;
  final String name;
  final String address;
  final String? tel;

  Office copyWith({String? name, String? address, String? tel}) {
    return Office(id: id, name: name ?? this.name, address: address ?? this.address, tel: tel ?? this.tel);
  }
}

/// 部署1件分。TimeFace2の`Department`モデル(`app/Models/Department.php`)に対応する。
/// 各部署は必ず1つの事業所(officeId)に属する。
class Department {
  const Department({required this.id, required this.name, required this.officeId, required this.officeName});

  final String id;
  final String name;
  final String officeId;
  final String officeName;

  Department copyWith({String? name, String? officeId, String? officeName}) {
    return Department(
      id: id,
      name: name ?? this.name,
      officeId: officeId ?? this.officeId,
      officeName: officeName ?? this.officeName,
    );
  }
}

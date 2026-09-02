/// システム管理者から全企業への一斉お知らせ1件分。TimeFace2の
/// `Admin\AnnouncementController`(企業お知らせ管理)に対応する。
class AdminAnnouncement {
  const AdminAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedDate,
  });

  final String id;
  final String title;
  final String body;
  final String publishedDate;

  AdminAnnouncement copyWith({String? title, String? body}) {
    return AdminAnnouncement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      publishedDate: publishedDate,
    );
  }
}

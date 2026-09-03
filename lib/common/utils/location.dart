import 'package:geolocator/geolocator.dart';

/// 打刻APIへ送る現在地(緯度・経度)を解決する関数の型。
///
/// 本番では [resolveCurrentLocation] を使うが、テストでは固定値を返す関数へ
/// 差し替えられるように typedef にしている。
typedef LocationResolver = Future<GeoLocation?> Function();

/// 打刻時に取得した端末の現在地。サーバーへは `latitude` / `longitude` として送る。
class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// 打刻APIのリクエストボディに載せる形式。
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// この端末の現在地を取得する。
///
/// 取得した緯度・経度は出勤打刻(`POST /attendance/start-work`)のパラメータとして
/// サーバーへ送られ、打刻場所の記録に使われる。
///
/// 位置情報サービスが無効・権限が拒否されている・取得がタイムアウトした等の場合は
/// 例外を投げず `null` を返す(位置が取れないことで打刻自体が失敗しないようにするため)。
Future<GeoLocation?> resolveCurrentLocation() async {
  try {
    // 端末の位置情報サービス(GPS等)がそもそもOFFなら取得を試みない
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // 取得が長引いても打刻をブロックしないよう時間制限を付ける
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (_) {
    // 権限エラー・タイムアウト・プラグイン未対応等でも打刻は継続させる
    return null;
  }
}

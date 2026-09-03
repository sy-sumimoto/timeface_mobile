import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// ログインAPI(`POST /api/mobile/login`)へ送る端末名を解決する関数の型。
///
/// 本番では [resolveDeviceName] を使うが、テストでは固定値を返す関数へ
/// 差し替えられるように typedef にしている。
typedef DeviceNameResolver = Future<String> Function();

/// APIの `device_name` 既定値。端末名を取得できなかった場合はこの値を送る
/// (サーバー側の未指定時デフォルトと同じ)。
const String _fallbackDeviceName = 'mobile-app';

/// この端末の名前を取得する。
///
/// 取得した値はサーバー側で Sanctum の個人アクセストークン名として保存され、
/// 「どの端末からログイン中か」の識別や、端末単位のログアウト管理に使われる。
///
/// 取得に失敗しても例外は投げず [_fallbackDeviceName] を返す
/// (端末名が取れないことでログイン自体が失敗しないようにするため)。
Future<String> resolveDeviceName() async {
  // Web では dart:io の Platform が使えないため機種名の取得は行わない
  if (kIsWeb) return _fallbackDeviceName;

  try {
    final info = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      // ios.name は利用者が設定した端末名(例: "山田のiPhone")。
      // 空のときは機種コード(例: "iPhone15,3")で代用する。
      final name = ios.name.trim();
      return name.isNotEmpty ? name : ios.utsname.machine;
    }

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      // メーカー名 + 機種名(例: "Google Pixel 7")
      final label = '${android.manufacturer} ${android.model}'.trim();
      return label.isNotEmpty ? label : _fallbackDeviceName;
    }

    // その他(Windows / macOS / Linux 等)は OS 名のみ
    return Platform.operatingSystem;
  } catch (_) {
    // プラグイン未対応・権限エラー等でもログインは継続させる
    return _fallbackDeviceName;
  }
}

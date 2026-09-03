# 認証付きAPIアクセスのログ([api.auth])だけをターミナルへライブ表示する。
#
# 使い方(timeface_mobile のルートで):
#   .\tool\watch_api_logs.ps1
#
# flutter run を起動していなくても、エミュレータ/実機でアプリが動いていれば拾える。
# 別ターミナルで動かしっぱなしにしておくと確認しやすい。

$ErrorActionPreference = "Stop"

# adb の場所(PATH に無ければ Android SDK の既定パスを使う)
$adb = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $adb) { $adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe" }
if (-not (Test-Path $adb)) { throw "adb が見つかりません: $adb" }

Write-Host "[api.auth] ログを監視中... (Ctrl+C で終了)" -ForegroundColor Cyan

# flutter タグの INFO 以上・タイムスタンプ無しの生メッセージだけを取り、
# [api.auth] とその続き3行(token / name / email)を表示する
& $adb logcat -s flutter:I --format=raw | Select-String -Pattern '\[api\.auth\]' -Context 0,3 |
    ForEach-Object {
        Write-Host ("-" * 60) -ForegroundColor DarkGray
        $_.Line
        $_.Context.PostContext
    }

/// サニタイズ済みHTML文字列を、ネイティブ表示用のプレーンテキストへ変換する。
///
/// お知らせ本文(`GET /api/mobile/announcements/{id}` の `message`)は
/// サニタイズ済みのHTML。アプリはHTMLレンダラを持たないため、
/// ブロック要素・改行を行区切りに落としたうえでタグを除去し、
/// HTMLエンティティをデコードして [Text] にそのまま渡せる文字列にする。
String htmlToPlainText(String html) {
  if (html.isEmpty) return '';

  var text = html;

  // <br> は改行
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

  // リスト項目は「・ 」を頭に付ける
  text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n・ ');

  // 段落・リストなどブロックの閉じは段落区切り(空行)、行内寄りの閉じは改行
  // (</li> は次の <li> 側で改行するのでここには含めない)
  text = text.replaceAll(
    RegExp(r'</(p|ul|ol|h[1-6]|blockquote|section|article)\s*>',
        caseSensitive: false),
    '\n\n',
  );
  text = text.replaceAll(
    RegExp(r'</(div|tr)\s*>', caseSensitive: false),
    '\n',
  );

  // 残りのタグをすべて除去
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');

  // HTMLエンティティのデコード
  text = _decodeEntities(text);

  // 各行の末尾空白を除去し、3行以上の空行は2行にまとめる
  text = text
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[ \t]+$'), ''))
      .join('\n');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return text.trim();
}

String _decodeEntities(String input) {
  var s = input
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'");

  // 数値文字参照 (&#123; / &#x1F600;)
  s = s.replaceAllMapped(
    RegExp(r'&#(x?)([0-9a-fA-F]+);'),
    (m) {
      final isHex = m.group(1) == 'x';
      final code = int.tryParse(m.group(2)!, radix: isHex ? 16 : 10);
      if (code == null) return m.group(0)!;
      try {
        return String.fromCharCode(code);
      } catch (_) {
        return m.group(0)!;
      }
    },
  );

  // &amp; は最後にデコード(二重デコード防止)
  return s.replaceAll('&amp;', '&');
}

import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/utils/html_text.dart';

/// サニタイズ済みHTML → プレーンテキスト変換の検証。

void main() {
  test('空文字はそのまま', () {
    expect(htmlToPlainText(''), '');
  });

  test('タグの無いプレーンテキストはそのまま(トリムのみ)', () {
    expect(htmlToPlainText('  こんにちは  '), 'こんにちは');
  });

  test('<p> は段落区切り(空行)、タグ自体は消える', () {
    expect(
      htmlToPlainText('<p>1行目です。</p><p>2行目です。</p>'),
      '1行目です。\n\n2行目です。',
    );
  });

  test('<br> は改行になる', () {
    expect(htmlToPlainText('あ<br>い<br/>う<br />え'), 'あ\nい\nう\nえ');
  });

  test('<ul><li> は「・ 」付きの箇条書きになる', () {
    expect(
      htmlToPlainText('<ul><li>りんご</li><li>みかん</li></ul>'),
      '・ りんご\n・ みかん',
    );
  });

  test('HTMLエンティティをデコードする', () {
    expect(
      htmlToPlainText('A &amp; B &lt;tag&gt; &quot;q&quot; &#39;a&#39; x&nbsp;y'),
      'A & B <tag> "q" \'a\' x y',
    );
  });

  test('数値文字参照をデコードする', () {
    expect(htmlToPlainText('&#12354;&#x3044;'), 'あい'); // あ / い
  });

  test('残ったタグはすべて除去する', () {
    expect(
      htmlToPlainText('<div class="x"><span>本文</span><strong>強調</strong></div>'),
      '本文強調',
    );
  });

  test('3行以上の空行は2行にまとめ、前後をトリムする', () {
    expect(
      htmlToPlainText('<p>a</p><p></p><p></p><p>b</p>'),
      'a\n\nb',
    );
  });
}

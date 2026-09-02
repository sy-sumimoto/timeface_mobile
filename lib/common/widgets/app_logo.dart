import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// TimeFaceのロゴ(assets/images/logo.svg)。HTMLモックの`.un_loginPage_cardLogo`
/// と同じ高さ24pxを既定値とし、幅はSVGの縦横比(230:34)に応じて自動で決まる。
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 24});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/images/logo.svg', height: height);
  }
}

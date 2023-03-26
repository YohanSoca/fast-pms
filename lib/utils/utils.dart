import 'dart:ui';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0x66000000);
}
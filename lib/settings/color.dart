import 'package:flutter/material.dart';

const myColorTheme = ColorScheme(
  brightness: Brightness.light,
  primary: MyColor.greenText,
  onPrimary: Color.fromARGB(255, 196, 202, 203),
  secondary: Color(0xFFFF9800),
  onSecondary: Colors.brown,
  error: Colors.red,
  onError: Colors.white,
  background: Color(0xFF678A74),
  onBackground: MyColor.greenText,
  surface: MyColor.greenLight,
  onSurface: MyColor.greenText,
);

class MyColor {
  static const Color green = Color(0xFF678A74);
  static const Color greenLight = Color(0xFF81A58E);
  static const Color greenSuperLight = Color(0xFFDBEEE2);
  static const Color greenDark = Color(0xFF4D705B);
  static const Color greenText = Color(0xFF20412C);
  static const Color pink = Color(0xFFFFA0A0);
  static const Color blueDark = Color(0xFF445174);
  static const Color blue = Color(0xFF57627E);
  static const Color lightBlue = Color(0xFF627BBD);
  static const Color superLightBlue = Color(0xFFA8CFEC);
  static const Color red = Color(0xFFD24343);
  static const Color lightRed = Color(0xFFE66654);
  static const Color brown = Color(0xFFD39365);
  static const Color lightBrown = Color(0xFFFBE1C2);
  static const Color lightYellow = Color(0xFFF2C177);
}

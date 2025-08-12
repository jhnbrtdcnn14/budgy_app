import 'package:flutter/material.dart';

class AppColors {
  // dynamic variables (will change when toggling theme)
  static Color primaryLight = const Color.fromARGB(255, 234, 247, 245);
  static Color secondaryLight = const Color.fromARGB(255, 200, 200, 200);
  static Color tertiaryLight = const Color.fromARGB(43, 200, 200, 200);
  static Color red = const Color.fromARGB(255, 221, 92, 92);
  static Color purple = const Color.fromARGB(255, 150, 46, 248);
  static Color primaryDark = const Color.fromARGB(255, 15, 15, 25);
  static Color textButton = const Color.fromARGB(255, 234, 247, 245);
  static Color darkpurple = const Color.fromARGB(255, 69, 20, 113);
  static Color green = const Color.fromARGB(255, 94, 221, 99);

  // light mode values
  static const _light_primaryLight = Color.fromARGB(255, 15, 15, 25);
  static const _light_secondaryLight = Color.fromARGB(255, 100, 100, 100);
  static const _light_tertiaryLight = Color.fromARGB(143, 252, 249, 255);
  static const _light_red = Color.fromARGB(255, 200, 50, 50);
  static const _light_purple = Color.fromARGB(255, 130, 30, 220);
  static const _light_primaryDark = Color.fromARGB(255, 234, 247, 245);
  static const _light_textButton = Color.fromARGB(255, 234, 247, 245);
  static const _light_darkpurple = Color.fromARGB(255, 195, 181, 233);
  static const _light_green = Color.fromARGB(255, 40, 160, 45);

  // dark mode values
  static const _dark_primaryLight = Color.fromARGB(255, 234, 247, 245);
  static const _dark_secondaryLight = Color.fromARGB(255, 200, 200, 200);
  static const _dark_tertiaryLight = Color.fromARGB(43, 200, 200, 200);
  static const _dark_red = Color.fromARGB(255, 221, 92, 92);
  static const _dark_purple = Color.fromARGB(255, 150, 46, 248);
  static const _dark_primaryDark = Color.fromARGB(255, 15, 15, 25);
  static const _dark_textButton = Color.fromARGB(255, 234, 247, 245);
  static const _dark_darkpurple = Color.fromARGB(255, 69, 20, 113);
  static const _dark_green = Color.fromARGB(255, 94, 221, 99);

  static void setDarkMode() {
    primaryLight = _dark_primaryLight;
    secondaryLight = _dark_secondaryLight;
    tertiaryLight = _dark_tertiaryLight;
    red = _dark_red;
    purple = _dark_purple;
    primaryDark = _dark_primaryDark;
    textButton = _dark_textButton;
    darkpurple = _dark_darkpurple;
    green = _dark_green;
  }

  static void setLightMode() {
    primaryLight = _light_primaryLight;
    secondaryLight = _light_secondaryLight;
    tertiaryLight = _light_tertiaryLight;
    red = _light_red;
    purple = _light_purple;
    primaryDark = _light_primaryDark;
    textButton = _light_textButton;
    darkpurple = _light_darkpurple;
    green = _light_green;
  }
}

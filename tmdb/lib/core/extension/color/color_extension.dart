import 'package:flutter/material.dart';

const MaterialColor myMainColor = MaterialColor(
  0xFFe17b82, // base = 500
  <int, Color>{
    50: Color(0xFFFFFFFF), // very lightest, almost white
    100: Color(0xFFFFE0E4), // softest pink tint
    200: Color(0xFFFFBFC7), // very soft pink
    300: Color(0xFFFF9FAE), // light pastel
    400: Color(0xFFF57F93), // softer red-pink
    500: Color(0xFFe17b82), // your main color
    600: Color(0xFFCC6F76), // slightly darker
    700: Color(0xFFB36266), // medium dark
    800: Color(0xFF994E54), // deeper shade
    900: Color(0xFF333333), // darkest, rich tone
  },
);

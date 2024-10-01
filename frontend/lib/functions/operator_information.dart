import 'package:flutter/cupertino.dart';
import 'package:olle_app/widgets/math_icons.dart';

/// This class is uses multiple static maps to convert an operator to different
/// types
class OperatorHandler {
  static const Map<String, String> toUnicode = {
    '+': '+',
    'p': '+',
    '-': '-',
    '*': '×',
    'm': '×',
    '/': '÷',
  };

  static const Map<String, Widget> toIcon = {
    '+': AddIcon(),
    'p': AddyIcon(),
    '-': SubIcon(),
    '*': MulIcon(),
    'm': MulyIcon(),
    '/': DivIcon(),
  };

  static const Map<String, Color> toColor = {
    '+': Color.fromRGBO(102, 108, 255, 1),
    'p': Color.fromRGBO(247, 171, 7, 1),
    '-': Color.fromRGBO(249, 74, 41, 1),
    '*': Color.fromRGBO(0, 223, 162, 1),
    'm': Color.fromRGBO(6, 234, 255, 1),
    '/': Color.fromRGBO(252, 226, 42, 1),
  };
}

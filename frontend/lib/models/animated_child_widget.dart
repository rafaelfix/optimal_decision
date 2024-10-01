import 'package:flutter/material.dart';

abstract class AnimatedChildWidget extends StatelessWidget {
  const AnimatedChildWidget({Key? key}) : super(key: key);
  double get height;
  double get width;
}

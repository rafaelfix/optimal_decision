import 'package:flutter/material.dart';

import '../models/animated_child_widget.dart';

/// Draws a ball with a border and a number within.
/// Calculates it's size based on:
/// Width of the screen
/// Amount of balls to fit on the screen
/// Given sizeFactor.
class NumberBall extends AnimatedChildWidget {
  final int number;
  final Color color;
  final Color? backgroundColor; // Optional background color
  final double sizeFactor;
  final int ballsPerRow;

  const NumberBall({
    required this.number,
    required this.color,
    this.backgroundColor =
        Colors.transparent, // Optional background color parameter
    required this.ballsPerRow,
    Key? key,
    this.sizeFactor = 0.8,
  }) : super(key: key);

  static const _inset = 2.0;
  static const _borderWidth = 2.0;
  static double widgetSize = 0;

  @override
  double get width {
    return widgetSize;
  }

  @override
  double get height {
    return widgetSize;
  }

  @override
  Widget build(BuildContext context) {
    var insetSize = _inset * ballsPerRow * 2;
    final size = (MediaQuery.of(context).size.width - insetSize) /
        ballsPerRow *
        sizeFactor;

    widgetSize = size + _inset * 2;
    final fontSize = size * 0.6;

    return Container(
      margin: const EdgeInsets.all(_inset),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backgroundColor, // Apply background color if specified
        shape: BoxShape.rectangle,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.black,
            width: _borderWidth,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number == -1 ? "" : (number).toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

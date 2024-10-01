import 'package:flutter/material.dart';

import '../widgets/point_should_click_icon.dart';
import './number_ball.dart';

/// A 'frame' of numbers ranging from 1 - 20.
/// Draws half-transparent balls on the n-first places determined by
/// [numTransparentBalls]
/// If a list of global keys is given, the frame will connect these keys to the
/// corresponding balls (to use for animating a flying ball).
class SummationFrame extends StatelessWidget {
  final List<NumberBall> ballFrame;
  final int numOfTransparentBalls;
  final Color transparentBallColor;
  final int numOfOtherColorTransparentBalls;
  final int nRows;
  final double sizeFactor;
  final List<GlobalKey>? keys;
  final bool shouldClick;
  final double shouldClickIconSize;
  final bool shouldHighlight;

  const SummationFrame({
    super.key,
    required this.ballFrame,
    required this.numOfTransparentBalls,
    required this.transparentBallColor,
    required this.nRows,
    this.numOfOtherColorTransparentBalls = 0,
    this.sizeFactor = 0.8,
    this.shouldClick = false,
    this.shouldClickIconSize = 40,
    this.keys,
    this.shouldHighlight = false,
  });

  /// Return one row of balls for the frame to be created
  Widget _createBallRow({
    required int offset,
    required Color color,
    required int rowSize,
    required List<NumberBall> ballFrame,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        rowSize,
        (index) {
          int currIndex = index + offset;
          bool highlightBall = currIndex < 10 && shouldHighlight;
          // Draw transparent balls when the list is exhausted.
          if (currIndex >= ballFrame.length) {
            return NumberBall(
              number: currIndex + 1,
              color: highlightBall ? Colors.white : Colors.transparent,
              ballsPerRow: rowSize,
              sizeFactor: sizeFactor,
              backgroundColor: highlightBall
                  ? (transparentBallColor == Colors.green
                      ? Colors.amber
                      : Colors.green)
                  : Colors.transparent,
            );
          }
          return ballFrame[currIndex];
        },
        growable: false,
      ),
    );
  }

  /// Return a frame of all drawn balls from the given List
  Widget _createBallFrame({
    required Color color,
    required int nRows,
    required List<NumberBall> ballFrame,
  }) {
    int numberOfRowsToMake;

    numberOfRowsToMake = 1 + (ballFrame.length ~/ (20 ~/ nRows));

    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: List.generate(
          numberOfRowsToMake,
          (rowIndex) => _createBallRow(
            offset: (20 ~/ nRows) * rowIndex,
            color: color,
            rowSize: 20 ~/ nRows,
            ballFrame: ballFrame,
          ),
        ),
      ),
    );
  }

  /// Return a row of empty balls for the empty frame
  Row _createEmptyRow({
    required int startNum,
    required int otherNum,
    required int offset,
    required Color color,
    required int rowSize,
  }) {
    //The opacity we want the clicked ball to have if it is less than the
    //starting number.
    double shadedOpacity = 0.3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        rowSize,
        (index) {
          int currIndex = index + offset;

          GlobalKey? currKey;
          if (keys != null) {
            currKey = (keys as List<GlobalKey>)[currIndex];
          }
          // Rita halvt-fylld cirkel
          if (currIndex < startNum) {
            return NumberBall(
              number: currIndex + 1,
              color: color.withOpacity(shadedOpacity),
              ballsPerRow: rowSize,
              key: currKey,
              sizeFactor: sizeFactor,
            );
            // Rita tomma cirklar
          } else if (currIndex < startNum + otherNum) {
            return NumberBall(
              number: currIndex + 1,
              color: color == Colors.green
                  ? Colors.yellow.withOpacity(shadedOpacity)
                  : Colors.green.withOpacity(shadedOpacity),
              ballsPerRow: rowSize,
              key: currKey,
              sizeFactor: sizeFactor,
            );
          } else {
            return NumberBall(
              number: currIndex + 1,
              color: Colors.white,
              ballsPerRow: rowSize,
              key: currKey,
              sizeFactor: sizeFactor,
            );
          }
        },
        growable: false,
      ),
    );
  }

  /// Return a complete frame of empty balls (1 - 20).
  Widget _createEmptyFrame({
    required int startNum,
    required Color color,
    required int otherNum,
    required int nRows,
  }) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: List.generate(
          nRows,
          (index) => _createEmptyRow(
            startNum: startNum,
            otherNum: otherNum,
            offset: (20 ~/ nRows) * index,
            color: color,
            rowSize: 20 ~/ nRows,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
      ),
      child: Stack(
        children: <Widget>[
          _createEmptyFrame(
            startNum: numOfTransparentBalls,
            otherNum: numOfOtherColorTransparentBalls,
            color: transparentBallColor,
            nRows: nRows,
          ),
          _createBallFrame(
            color: transparentBallColor,
            nRows: nRows,
            ballFrame: ballFrame,
          ),
          shouldClick
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: PointShouldClickIcon(
                    iconSize: shouldClickIconSize,
                  ),
                )
              : const Center(),
        ],
      ),
    );
  }
}

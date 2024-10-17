import 'package:flutter/material.dart';

/// Number ball
class _NumberBall extends StatefulWidget {
  final int number;
  final Color ballColor;
  final bool isAxis;
  final Function(int)? onPressed;

  const _NumberBall(
      {Key? key,
      required this.number,
      this.ballColor = Colors.grey,
      this.isAxis = false,
      this.onPressed})
      : super(key: key);

  @override
  State<_NumberBall> createState() => _NumberBallState();
}

class _NumberBallState extends State<_NumberBall> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: (!widget.isAxis)
            ? const EdgeInsets.all(2.0)
            : const EdgeInsets.all(0.0),
        child: GestureDetector(
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed!(widget.number);
            }
          },
          child: Container(
            decoration: (!widget.isAxis)
                ? BoxDecoration(
                    color: widget.ballColor,
                    border: Border.all(color: Colors.black),
                    // TODO: Fix hard coded radius
                    borderRadius: BorderRadius.circular(100),
                  )
                : BoxDecoration(
                    color: widget.ballColor,
                    border: Border.all(color: Colors.black),
                    // TODO: Fix hard coded radius
                    borderRadius: BorderRadius.circular(100),
                  ),
            child: Center(
              child: Text(
                widget.number.toString(),
              ),
            ),
          ),
        ));
  }
}

/// Simple number grid
class SimpleNumberGrid extends StatefulWidget {
  final int x;
  final int y;
  final Color ballColor;
  final Color backgroundColor;
  final int countStartOffset;
  final int perRowOffset;
  final bool isAxis;
  final Function(int)? onPressed;

  const SimpleNumberGrid(
      {Key? key,
      required this.x,
      required this.y,
      required this.ballColor,
      required this.backgroundColor,
      this.countStartOffset = 0,
      this.perRowOffset = 0,
      this.isAxis = false,
      this.onPressed})
      : super(key: key);

  @override
  State<SimpleNumberGrid> createState() => SimpleNumberGridState();
}

class SimpleNumberGridState extends State<SimpleNumberGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.x <= 0 || widget.y <= 0) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }

    return AspectRatio(
      aspectRatio: widget.x / widget.y,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          GridView.builder(
            itemCount: widget.x * widget.y,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.x),
            itemBuilder: (BuildContext ctx, index) {
              int offset = widget.countStartOffset;
              // int offset = 0;
              if (widget.perRowOffset != 0) {
                offset += (index ~/ widget.x) * widget.perRowOffset;
              }
              return _NumberBall(
                number: index + 1 + offset,
                ballColor: widget.ballColor,
                isAxis: widget.isAxis,
                onPressed: widget.onPressed,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Divided number grid
class DividedNumberGrid extends StatefulWidget {
  final int x;
  final int y;
  final Color primaryBallColor;
  final Color primaryBackgroundColor;
  final Color secondaryBallColor;
  final Color secondaryBackgroundColor;
  final int dividerPos;
  final bool horizontalDivider;
  final double dividerSpacing;
  final bool continuousNumbers;
  final bool doFlex;
  final bool isAxis;
  final Function(int)? onPressed;

  const DividedNumberGrid({
    Key? key,
    required this.x,
    required this.y,
    // TODO: Fix colors
    this.primaryBallColor = const Color(0xFF64B5F6),
    this.primaryBackgroundColor = const Color(0xFFBBDEFB),
    this.secondaryBallColor = const Color(0xFFE57373),
    this.secondaryBackgroundColor = const Color(0xFFFFCDD2),
    this.dividerPos = 0,
    this.horizontalDivider = true,
    this.dividerSpacing = 0.0,
    this.continuousNumbers = true,
    this.doFlex = false,
    this.isAxis = false,
    this.onPressed,
  }) : super(key: key);

  @override
  State<DividedNumberGrid> createState() => _DividedNumberGridState();
}

class _DividedNumberGridState extends State<DividedNumberGrid> {
  @override
  Widget build(BuildContext context) {
    int dividerMaxLimit = (widget.horizontalDivider ? widget.y : widget.x);
    int clampedDividerPos;

    if (widget.dividerPos <= 0) {
      clampedDividerPos = dividerMaxLimit;
    } else if (widget.dividerPos > dividerMaxLimit) {
      clampedDividerPos = dividerMaxLimit;
    } else {
      clampedDividerPos = widget.dividerPos;
    }

    int x1 = widget.horizontalDivider ? widget.x : clampedDividerPos;
    int y1 = widget.horizontalDivider ? clampedDividerPos : widget.y;

    int x2 = widget.horizontalDivider ? widget.x : widget.x - clampedDividerPos;
    int y2 = widget.horizontalDivider ? widget.y - clampedDividerPos : widget.y;

    var flexScaler = 1;
    if (widget.doFlex) {
      flexScaler = widget.dividerSpacing.toInt();
    }

    return Flex(
      direction: widget.horizontalDivider ? Axis.vertical : Axis.horizontal,
      children: [
        Flexible(
          flex: flexScaler * (widget.horizontalDivider ? y1 : x1),
          child: SimpleNumberGrid(
            x: x1,
            y: y1,
            ballColor: widget.primaryBallColor,
            backgroundColor: widget.primaryBackgroundColor,
            countStartOffset: 0,
            perRowOffset: widget.continuousNumbers
                ? (widget.horizontalDivider ? 0 : x2)
                : 0,
            isAxis: widget.isAxis,
            onPressed: widget.onPressed,
          ),
        ),
        !widget.doFlex
            ? SizedBox(
                width: widget.dividerSpacing,
                height: widget.dividerSpacing,
              )
            : (widget.dividerPos != 0)
                ? const Spacer(
                    flex: 1,
                  )
                : const SizedBox.shrink(),
        Flexible(
          flex: flexScaler * (widget.horizontalDivider ? y2 : x2),
          child: SimpleNumberGrid(
            x: x2,
            y: y2,
            ballColor: widget.secondaryBallColor,
            backgroundColor: widget.secondaryBackgroundColor,
            countStartOffset: widget.continuousNumbers
                ? (widget.horizontalDivider ? widget.x * widget.dividerPos : x1)
                : 0,
            perRowOffset: widget.continuousNumbers
                ? (widget.horizontalDivider ? 0 : x1)
                : 0,
            isAxis: widget.isAxis,
            onPressed: widget.onPressed,
          ),
        ),
      ],
    );
  }
}

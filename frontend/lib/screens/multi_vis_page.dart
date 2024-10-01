import 'package:flutter/material.dart';
import 'package:olle_app/widgets/confetti.dart';
import 'package:olle_app/widgets/number_grid.dart';
import 'dart:math' as math;

/// Creates a visual representation of multiplication.
/// [x] is the first value [y] is the second
/// if [isUnknown] then the variables are instead used as:
/// [y] * answer = [x]
// ignore: must_be_immutable
class MultiVisPage extends StatefulWidget {
  int x;
  int y;
  bool isUnknown;
  MultiVisPage(
      {Key? key, required this.x, required this.y, required this.isUnknown})
      : super(key: key);

  @override
  _MultiVisPageState createState() => _MultiVisPageState();
}

class _MultiVisPageState extends State<MultiVisPage> {
  int leftDivider = 0;
  int topDivider = 3;
  double dividerSpacing = 1;
  bool horizontalDivide = true;
  int activeDivider = 0;
  // used when isUnknown = true
  int answer = 0;
  //TODO: change to Theme.of(context)...
  Color part1Main = Colors.green;
  Color part1Background = Colors.green[200] as Color;
  Color part2Main = Colors.amber;
  Color part2Background = Colors.amber[200] as Color;
  Color axisMain = Colors.transparent;
  Color axisBackground = Colors.transparent;
  final confettiWidget = Confetti(
    doToast: false,
  );
  @override
  void initState() {
    super.initState();
    //widget.isUnknown = false;
    if (widget.isUnknown) {
      answer = widget.x;
      widget.x = 1;
    }
  }

  /// 0 = none, 1 = topMid, 2 = topRight, 3 = leftMid, 4 = leftBottom
  /// used when the grid gets divided into multiple parts
  void setActiveDivider(int num) {
    if (num == activeDivider) {
      activeDivider = 0;
    } else {
      activeDivider = num;
    }
  }

  double getFontSize() {
    if (widget.isUnknown) {
      return 8.5;
    }
    switch (widget.x) {
      case 10:
        {
          return 8.5;
        }
      case 9:
        {
          return 10;
        }
      case 8:
        {
          return 11;
        }
      case 7:
        {
          return 12;
        }
      default:
        {
          return 13;
        }
    }
  }

  /// Increases the amount of columns by 1. Only used if isUnknown is true
  void setColumnCount(int count) {
    if (!widget.isUnknown || count > 10) {
      return;
    }
    if (widget.x * widget.y != answer) {
      setState(() {
        widget.x = count;
      });
    }
    if (widget.x * widget.y == answer) {
      confettiWidget.playConfetti();
    }
  }

  // Creates the entire summation seen on the right side of the screen
  Widget getRightSummation(int index) {
    double fontSize = getFontSize();
    String toReturn;
    if (index == 0) {
      toReturn = "+" + widget.x.toString();
      return Center(
        child: Text(
          toReturn,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      );
    }

    if (index == leftDivider - 1) {
      return Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              "+" + (widget.x).toString(),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            child: Center(
              child: Text(
                (widget.x * leftDivider).toString(),
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      );
    } else if (index == leftDivider) {
      toReturn = "";
    } else if (leftDivider == 0 && index == widget.y - 1) {
      return Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              "+" + (widget.x).toString(),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            child: Center(
              child: Text(
                (widget.x * widget.y).toString(),
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      );
    } else if (index == widget.y) {
      return Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              "+" + (widget.x).toString(),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            child: Center(
              child: Text(
                (widget.x * widget.y).toString(),
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      );
    } else {
      toReturn = "+" + widget.x.toString();
    }

    return Center(
      child: Text(
        toReturn,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }

  Flex rightSummer() {
    return Flex(
      direction: Axis.vertical,
      children: [
        Flexible(
          flex: (leftDivider == 0 ? widget.y : widget.y + 1),
          child: AspectRatio(
            aspectRatio: (leftDivider == 0 ? 1 / widget.y : 1 / (widget.y + 1)),
            child: Stack(
              children: [
                GridView.builder(
                  itemCount: (leftDivider == 0 ? widget.y : widget.y + 1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1),
                  itemBuilder: (BuildContext ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: getRightSummation(index),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column getBottomButton() {
    Spacer spacer;
    int flexValue;

    if (widget.y == 1) {
      return const Column();
    } else if (widget.y == 2) {
      spacer = const Spacer(
        flex: 1,
      );
      flexValue = 1;
    } else if (leftDivider == 0) {
      spacer = Spacer(
        flex: (widget.y - 2),
      );
      flexValue = 2;
    } else {
      if (activeDivider == 3) {
        spacer = Spacer(
          flex: (widget.y - 1),
        );
        flexValue = 2;
      } else {
        spacer = Spacer(
          flex: (widget.y - 2),
        );
        flexValue = 3;
      }
    }

    return Column(
      children: [
        spacer,
        Flexible(
          child: Center(
            child: IconButton(
              iconSize: 30, // TODO ej hårdkoda
              padding: EdgeInsets.zero,

              icon: const Icon(Icons.unfold_more),
              onPressed: () {
                setState(
                  () {
                    setActiveDivider(4);
                  },
                );
              },
            ),
          ),
          flex: flexValue,
        ),
        (widget.y == 2)
            ? const Spacer(
                flex: 1,
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Row getTopRightButton(int num) {
    Spacer spacer;
    int flexValue;

    if (widget.x == 1) {
      return const Row();
    } else if (topDivider == 0) {
      spacer = Spacer(
        flex: (1 + widget.x - 2),
      );
      flexValue = 2;
    } else {
      if (activeDivider == 1) {
        spacer = Spacer(
          flex: (1 + widget.x - 1),
        );
        flexValue = 2;
      } else {
        spacer = Spacer(
          flex: (1 + widget.x - 2),
        );
        flexValue = 3;
      }
    }

    return Row(
      children: [
        spacer,
        Flexible(
          child: Center(
              child: Transform.rotate(
            angle: math.pi / 2,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 30,
              icon: const Icon(Icons.unfold_more),
              onPressed: () {
                setState(
                  () {
                    setActiveDivider(2);
                  },
                );
              },
              // child: null,
            ),
          )),
          flex: flexValue,
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // used instead of widget.x if we don't want the grid to scale
    int widgetX = widget.isUnknown ? 10 : widget.x;
    switch (activeDivider) {
      case 0:
        leftDivider = 0;
        topDivider = 0;
        break;
      case 1:
        leftDivider = 0;
        topDivider = widgetX ~/ 2;
        break;
      case 2:
        leftDivider = 0;
        topDivider = widgetX - 1;
        break;
      case 3:
        leftDivider = widget.y ~/ 2;
        topDivider = 0;
        break;
      case 4:
        leftDivider = widget.y - 1;
        topDivider = 0;
        break;
      default:
        leftDivider = 0;
        topDivider = 0;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUnknown
              ? "${widget.y} x Y = $answer"
              : "${widget.x} x ${widget.y}",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: confettiWidget,
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: AspectRatio(
                    aspectRatio: (leftDivider != 0)
                        ? (widgetX + 2) / (widget.y + 2)
                        : (topDivider != 0)
                            ? (widgetX + 3) / (widget.y + 1)
                            : (widgetX + 2) / (widget.y + 1),
                    child: Column(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Flexible(
                                        flex:
                                            (topDivider == 0) ? (10) : (10 + 1),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 2.0,
                                                  color: Colors.black),
                                              top: BorderSide(
                                                  width: 2.0,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        )),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                                width: 2.0,
                                                color: Colors.black),
                                            bottom: BorderSide(
                                                width: 2.0,
                                                color: Colors.black),
                                          ),
                                        ),
                                        child: Center(
                                          child: widget.isUnknown
                                              ? IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: widget.isUnknown
                                                      ? 36 - 10
                                                      : 36 - widgetX * 1,
                                                  icon: const Icon(
                                                    Icons.add_circle_rounded,
                                                  ),
                                                  onPressed: () {
                                                    setColumnCount(
                                                        widget.x + 1);
                                                  },
                                                )
                                              : IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: widget.isUnknown
                                                      ? 36 - 10
                                                      : 36 - widgetX * 1,
                                                  icon: const Icon(Icons
                                                      .wifi_protected_setup),
                                                  onPressed: () {
                                                    setState(() {
                                                      var tempY = widget.y;
                                                      widget.y = widget.x;
                                                      widget.x = tempY;
                                                      switch (activeDivider) {
                                                        case 1:
                                                          activeDivider = 3;
                                                          break;
                                                        case 2:
                                                          activeDivider = 4;
                                                          break;
                                                        case 3:
                                                          activeDivider = 1;
                                                          break;
                                                        case 4:
                                                          activeDivider = 2;
                                                          break;
                                                        default:
                                                          break;
                                                      }
                                                    });
                                                  },
                                                ),
                                        ),
                                      ),
                                      flex: 1,
                                    ),
                                    Flexible(
                                      child: DividedNumberGrid(
                                        primaryBallColor: axisMain,
                                        primaryBackgroundColor: axisBackground,
                                        secondaryBallColor: axisMain,
                                        secondaryBackgroundColor:
                                            axisBackground,
                                        x: widgetX,
                                        y: 1,
                                        dividerPos: topDivider,
                                        doFlex: true,
                                        dividerSpacing: dividerSpacing,
                                        horizontalDivider: false,
                                        isAxis: true,
                                        onPressed: setColumnCount,
                                      ),
                                      flex: topDivider == 0
                                          ? widgetX
                                          : widgetX + 1,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                (widget.x % 2 == 0 &&
                                        widget.x > 3 &&
                                        !widget.isUnknown)
                                    ? Row(
                                        children: [
                                          const Spacer(),
                                          Flexible(
                                            child: Center(
                                              child: Transform.rotate(
                                                angle: math.pi / 2,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 30,
                                                  icon: const Icon(
                                                      Icons.unfold_more),
                                                  onPressed: () {
                                                    setState(
                                                      () {
                                                        setActiveDivider(1);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            flex: topDivider == 0
                                                ? widget.x
                                                : widget.x + 1,
                                          ),
                                          activeDivider == 2
                                              ? const Spacer(
                                                  flex: 2,
                                                )
                                              : const Spacer(),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                widget.isUnknown
                                    ? const SizedBox.shrink()
                                    : getTopRightButton(2),
                              ],
                            )),
                        Flexible(
                          flex: leftDivider == 0 ? widget.y : widget.y + 1,
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: DividedNumberGrid(
                                      x: 1,
                                      y: widget.y,
                                      dividerPos: leftDivider,
                                      dividerSpacing: dividerSpacing,
                                      doFlex: true,
                                      primaryBallColor: axisMain,
                                      primaryBackgroundColor: axisBackground,
                                      secondaryBallColor: axisMain,
                                      secondaryBackgroundColor: axisBackground,
                                      isAxis: true,
                                    ),
                                    flex: 1,
                                  ),
                                  (topDivider == 0)
                                      ? Flexible(
                                          child: DividedNumberGrid(
                                            x: widget.x,
                                            y: widget.y,
                                            dividerPos: leftDivider,
                                            dividerSpacing: dividerSpacing,
                                            doFlex: true,
                                            horizontalDivider: true,
                                            primaryBallColor: part1Main,
                                            secondaryBallColor: part2Main,
                                            primaryBackgroundColor:
                                                part1Background,
                                            secondaryBackgroundColor:
                                                part2Background,
                                          ),
                                          flex: widgetX,
                                        )
                                      : Flexible(
                                          child: DividedNumberGrid(
                                            x: widget.x,
                                            y: widget.y,
                                            dividerPos: topDivider,
                                            dividerSpacing: dividerSpacing,
                                            doFlex: true,
                                            horizontalDivider: false,
                                            primaryBallColor: part1Main,
                                            secondaryBallColor: part2Main,
                                            primaryBackgroundColor:
                                                part1Background,
                                            secondaryBackgroundColor:
                                                part2Background,
                                          ),
                                          flex: widgetX + 1),
                                  rightSummer(),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                                width: 2.0,
                                                color: Colors.black),
                                            right: BorderSide(
                                                width: 2.0,
                                                color: Colors.black),
                                          ),
                                        ),
                                        child: widget.isUnknown
                                            ? const SizedBox.shrink()
                                            : getBottomButton()),
                                    flex: 1,
                                  ),
                                  topDivider == 0
                                      ? Spacer(
                                          flex: widgetX + 1,
                                        )
                                      : Spacer(
                                          flex: widgetX + 2,
                                        ),
                                ],
                              ),
                              (widget.y % 2 == 0 &&
                                      widget.y > 3 &&
                                      widget.isUnknown)
                                  ? Row(
                                      children: [
                                        Flexible(
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  child: Center(
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      iconSize: 30,
                                                      icon: const Icon(
                                                          Icons.unfold_more),
                                                      onPressed: () {
                                                        setState(
                                                          () {
                                                            setActiveDivider(3);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  flex: widget.y),
                                              activeDivider == 4
                                                  ? const Spacer(
                                                      flex: 1,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                          flex: 1,
                                        ),
                                        topDivider == 0
                                            ? Spacer(
                                                flex: widgetX + 1,
                                              )
                                            : Spacer(
                                                flex: widgetX + 2,
                                              ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  flex: 8,
                ),
                leftDivider != 0
                    ? IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  leftDivider.toString(),
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: part1Main,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                Container(
                                  child: Text(
                                    "x" + widget.x.toString(),
                                    style: TextStyle(
                                      fontSize: 26,
                                      color: part1Main,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 3.0,
                                        color: part1Main,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  (leftDivider * widget.x).toString(),
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: part1Main,
                                  ),
                                )
                              ],
                            ),
                            const Spacer(
                              flex: 5,
                            ),
                            Container(
                              height: 100,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  (widget.y - leftDivider).toString(),
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: part2Main,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "x" + widget.x.toString(),
                                    style: TextStyle(
                                      fontSize: 26,
                                      color: part2Main,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 3.0,
                                        color: part2Main,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  ((widget.y - leftDivider) * widget.x)
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: part2Main,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            flex: 8,
          ),
          (topDivider != 0)
              ? Row(
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    Flexible(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              topDivider.toString(),
                              style: TextStyle(
                                fontSize: 26,
                                color: part1Main,
                              ),
                            ),
                            Container(
                              child: Text(
                                "x" + widget.y.toString(),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: part1Main,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 3.0,
                                    color: part1Main,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              (topDivider * widget.y).toString(),
                              style: TextStyle(
                                fontSize: 26,
                                color: part1Main,
                              ),
                            )
                          ],
                        ),
                      ),
                      flex: topDivider + 1,
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Flexible(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              (widget.x - topDivider).toString(),
                              style: TextStyle(
                                fontSize: 26,
                                color: part2Main,
                              ),
                            ),
                            Container(
                              child: Text(
                                "x" + widget.y.toString(),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: part2Main,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 3.0,
                                    color: part2Main,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              ((widget.x - topDivider) * widget.y).toString(),
                              style: TextStyle(
                                fontSize: 26,
                                color: part2Main,
                              ),
                            )
                          ],
                        ),
                      ),
                      flex: widget.x - topDivider + 1,
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 2.0,
                  color: Colors.black,
                ),
              ),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Visibility(
                    visible: widget.isUnknown,
                    child: Column(children: [
                      Text(
                        "${widget.y} x ${widget.x} = ${widget.y * widget.x}",
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        "${widget.y} x Y = $answer",
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        widget.x * widget.y == answer
                            ? "Y = " + widget.x.toString()
                            : "Y =",
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ]),
                  ),
                ]),
                const Spacer(
                  flex: 10,
                ),
                (leftDivider != 0)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (leftDivider * widget.x).toString(),
                            style: TextStyle(
                              fontSize: 30,
                              color: part1Main,
                            ),
                          ),
                          Container(
                            child: Text(
                              "+" +
                                  ((widget.y - leftDivider) * widget.x)
                                      .toString(),
                              style: TextStyle(
                                fontSize: 30,
                                color: part2Main,
                              ),
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 3.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            (widget.x * widget.y).toString(),
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          )
                        ],
                      )
                    : (topDivider != 0)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                (topDivider * widget.y).toString(),
                                style: TextStyle(
                                  fontSize: 30,
                                  color: part1Main,
                                ),
                              ),
                              Container(
                                child: Text(
                                  "+" +
                                      ((widget.x - topDivider) * widget.y)
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: part2Main,
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 3.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                (widget.x * widget.y).toString(),
                                style: const TextStyle(
                                  fontSize: 30,
                                ),
                              )
                            ],
                          )
                        : const SizedBox.shrink(),
                const Spacer(),
                (topDivider != 0 || leftDivider != 0)
                    ? const Text(
                        "=",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      )
                    : const SizedBox.shrink(),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        widget.y.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                    ),
                    Container(
                      child: Text(
                        "x" + widget.x.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 3.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      (widget.x * widget.y).toString(),
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

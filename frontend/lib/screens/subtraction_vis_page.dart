import 'package:flutter/material.dart';

import 'package:olle_app/widgets/number_ball.dart';
import 'package:olle_app/widgets/summation_frame.dart';
import 'package:olle_app/widgets/glowing_icon_button.dart';
import 'package:olle_app/widgets/elevated_back_button.dart';
import 'package:olle_app/widgets/animated_child_positioned.dart';
import 'package:olle_app/widgets/confetti.dart';

/// Represents a way to visualize a subtraction question
/// [startX] and [startY] are the values getting subtracted
// ignore: must_be_immutable
class SubtractionVisPage extends StatefulWidget {
  late int _originalStartX;
  late int _originalStartY;

  // Start values of the question.
  int startX;
  int startY;
  int startZ = 0;

  bool showBackButton = false;

  SubtractionVisPage({
    super.key,
    required this.startX,
    required this.startY,
  }) {
    _originalStartX = startX;
    _originalStartY = startY;
  }

  void resetNumbers() {
    startX = _originalStartX;
    startY = _originalStartY;
  }

  @override
  State<SubtractionVisPage> createState() => _SubtractionVisPageState();
}

class _SubtractionVisPageState extends State<SubtractionVisPage> {
  late double animationLeftOffset = 0;
  late double animationTopOffset = 0;

  /// GlobalKeys to be used for finding areas on the screen for animations
  /// Used in [_animateMoveOneBall]
  List<GlobalKey> xKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> yKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> zKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> aKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> bKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> cKeys = List.generate(20, (index) => GlobalKey());

  // The first set of ballFrames. Gets drawn on the page with balls in them.
  late List<NumberBall> ballFrameX;
  late List<NumberBall> ballFrameY;
  late List<NumberBall> ballFrameZ;

  // The second set that is shown after the initial animations are done.
  late List<NumberBall> ballFrameA;
  late List<NumberBall> ballFrameB;
  late List<NumberBall> ballFrameC;

  //TODO: change to Theme.of(context)...
  static const Color colorX = Colors.green;
  static const Color colorY = Colors.amber;
  static const frameRows = 2;
  static const ballsPerRow = 20 ~/ frameRows;

  // The animator for the page as well as various variables used to create animations.
  late AnimatedChildPositioned ballAnimator;
  List<NumberBall> ballFrameBeingMovedTo = [];
  bool shouldReplaceBall = false;
  late NumberBall ballBeingAnimated = const NumberBall(
    number: -1,
    color: Colors.black,
    ballsPerRow: ballsPerRow,
  );

  // Used for chaining animations
  late List<Function> animationQueue = [];

  final confettiWidget = Confetti(
    doToast: false,
  );

  @override
  void initState() {
    super.initState();
    ballAnimator = AnimatedChildPositioned(
      onCompleted: onAnimationComplete,
    );
    initList();
  }

  void initList() {
    // Only ballFrame A and Z contain anyting at the start.
    ballFrameZ = [];
    ballFrameY = [];
    ballFrameB = [];
    ballFrameC = [];

    ballFrameY = List.generate(
      widget.startY,
      (index) => NumberBall(
        number: index + 1,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
      growable: true,
    );

    if (widget.startY == 0) {
      ballFrameX = List.generate(
        1,
        (index) => NumberBall(
          number: index + 1,
          color: colorX,
          ballsPerRow: ballsPerRow,
        ),
        growable: true,
      );
    } else {
      ballFrameX = [];
    }
    // Contains X balls. The last Y balls are a different colour.
    ballFrameA = List.generate(
      widget.startX,
      (index) => NumberBall(
        number: index + 1,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
      growable: true,
    );
    for (int i = ballFrameA.length - 1;
        i >= ballFrameA.length - widget.startY;
        i--) {
      ballFrameA[i] = NumberBall(
        number: ballFrameA[i].number,
        color: colorX,
        ballsPerRow: ballsPerRow,
      );
    }
    // Copying ballFrameZ
  }

  // Called when the animation completes. Doesn't work unless more than one animation has played.
  void onAnimationComplete() {
    ballFrameBeingMovedTo.add(ballBeingAnimated);
    if (ballFrameZ.length != widget.startX && ballFrameY.isEmpty) {
      ballFrameX.add(
        NumberBall(
          number: ballFrameX.length + 1,
          color: colorX,
          ballsPerRow: ballsPerRow,
        ),
      );
    }

    if (animationQueue.isNotEmpty) {
      var func = animationQueue.removeAt(0);
      func();
    } else {
      // The user has reached a state where it is not expected to do anything.
      // A backbutton is shown to indicate completion.
      if (ballFrameC.length == (widget.startX - widget.startY) &&
          ballFrameB.length == widget.startY) {
        widget.showBackButton = true;
        confettiWidget.playConfetti();
      }
      // Empty setState used to rebuild the screen so that the ball that was just
      // animated is shown to have "landed" in place
      // (otherwise the position on the screen will be empty)
      setState(() {});
    }
  }

  /// Get an offset that represents the coordinates of one NumberBall or empty slot in [keys]
  Offset _getOffset(int index, List<GlobalKey> keys) {
    late RenderBox renderBox;
    renderBox = keys[index].currentContext?.findRenderObject() as RenderBox;

    Offset pixelOffset = renderBox.localToGlobal(Offset.zero);

    return Offset(pixelOffset.dx,
        pixelOffset.dy - MediaQuery.of(context).padding.top - kToolbarHeight);
  }

  // Returns an animation to the ballAnimator
  void _animateMoveOneBall(
      List<NumberBall> ballFrameToMoveFrom,
      List<NumberBall> ballFrameToMoveTo,
      List<GlobalKey> keysFrom,
      List<GlobalKey> keysTo,
      {int? ballToMoveIndex}) {
    _moveOneBall(
      ballFrameToMoveFrom: ballFrameToMoveFrom,
      ballFrameToMoveTo: ballFrameToMoveTo,
      keysFrom: keysFrom,
      keysTo: keysTo,
      ballToMoveIndex: ballToMoveIndex,
    );
  }

  /// Moves one ball between two [ballFrames].
  /// [ballFrameToMoveFrom] and [keysFrom] must represent the same ballframe.
  /// Same with [ballFrameToMoveTo] and [keysTo]
  void _moveOneBall({
    required List<NumberBall> ballFrameToMoveFrom,
    required List<NumberBall> ballFrameToMoveTo,
    required List<GlobalKey> keysFrom,
    required List<GlobalKey> keysTo,
    int? ballToMoveIndex,
  }) {
    ballFrameBeingMovedTo = ballFrameToMoveTo;
    widget.showBackButton = false;
    int startIndex;

    // Default to always moving the last ball in the list if no value for index is given
    if (ballToMoveIndex == null) {
      startIndex = ballFrameToMoveFrom.length - 1;
    } else {
      startIndex = ballToMoveIndex;
    }

    // Endindex is always the first empty slot in the ballFrame that we are moving to.
    var endIndex = ballFrameToMoveTo.length;

    // Get the coordinates of the ball we sohould move.
    Offset startOffset = _getOffset(startIndex, keysFrom);
    // Get coordinates of the empty slot it should move to.
    Offset endOffset = _getOffset(endIndex, keysTo);

    // Remove the ball that should be moved.

    if (shouldReplaceBall) {
      ballBeingAnimated = ballFrameToMoveFrom[startIndex];

      NumberBall replaceBall = NumberBall(
        number: ballBeingAnimated.number,
        color: ballBeingAnimated.color.withOpacity(0.3),
        ballsPerRow: ballsPerRow,
      );
      ballFrameToMoveFrom[startIndex] = replaceBall;
    } else {
      ballBeingAnimated = ballFrameToMoveFrom.removeAt(startIndex);
    }

    ballBeingAnimated = NumberBall(
      number: endIndex + 1,
      color: ballBeingAnimated.color,
      ballsPerRow: ballsPerRow,
    );

    var ballRowToChange = ballFrameToMoveFrom;

    for (var i = startIndex; i < ballRowToChange.length; i++) {
      ballRowToChange[i] = NumberBall(
        number: i + 1,
        color: ballRowToChange[i].color,
        ballsPerRow: ballsPerRow,
      );
    }

    setState(() {
      animationLeftOffset = startOffset.dx;
      animationTopOffset = startOffset.dy;
    });
    ballAnimator.startAnimateChild(
      child: NumberBall(
        number: -1,
        color: ballBeingAnimated.color,
        ballsPerRow: ballsPerRow,
      ),
      startOffset: startOffset,
      endOffset: endOffset,
    );
  }

  void _ballFrameYTapFunction() {
    if (ballFrameY.isEmpty || ballAnimator.isAnimating) {
      return;
    }
    shouldReplaceBall = false;
    animationQueue.addAll(
      List.generate(
        ballFrameY.length,
        (index) => () => _animateMoveOneBall(
              ballFrameY,
              ballFrameZ,
              yKeys,
              zKeys,
            ),
      ),
    );
    _playAnimation();
  }

  void _ballFrameXTapFunction() {
    if (ballFrameX.last.color != Colors.green) {
      return;
    }
    shouldReplaceBall = true;
    animationQueue.addAll(
      List.generate(
        1,
        (index) => () => _animateMoveOneBall(
              ballFrameX,
              ballFrameZ,
              xKeys,
              zKeys,
              ballToMoveIndex: ballFrameX.length - 1,
            ),
      ),
    );
    _playAnimation();
  }

  /// Moves the balls from [ballFrameZ] to different frames depending on how many balls there are in [ballFrameZ]
  void _ballFrameZTapFunction() {
    shouldReplaceBall = false;
    if (ballFrameZ.isEmpty || ballAnimator.isAnimating) {
      return;
    }
    // If no balls have been moved we move to ballFrameY
    if (ballFrameZ.length == widget.startX && widget.startY != 0) {
      animationQueue.addAll(
        List.generate(
          widget.startY,
          (index) => () => _animateMoveOneBall(
                ballFrameZ,
                ballFrameY,
                zKeys,
                yKeys,
              ),
        ),
      );
    }
    // Otherwise we move to ballFrameX
    else {
      animationQueue.addAll(
        List.generate(
          widget.startX - widget.startY,
          (index) => () => _animateMoveOneBall(
                ballFrameZ,
                ballFrameX,
                zKeys,
                xKeys,
              ),
        ),
      );
    }
    _playAnimation();
  }

  /// Moves the balls from [ballFrameA] to different frames depending on how many balls there are in [ballFrameA]
  void _ballFrameATapFunction() {
    if (ballAnimator.isAnimating ||
        !_shouldShowSecondSet() ||
        ballFrameA.isEmpty) {
      return;
    }
    shouldReplaceBall = false;
    // if no balls have been moved we move to ballFrameB
    if (ballFrameA.length == widget.startX && widget.startY != 0) {
      animationQueue.addAll(
        List.generate(
          widget.startY,
          (index) => () => _animateMoveOneBall(
                ballFrameA,
                ballFrameB,
                aKeys,
                bKeys,
              ),
        ),
      );
    }
    // if balls have been moved previously we move to ballFrameC
    else {
      animationQueue.addAll(
        List.generate(
          widget.startX - widget.startY,
          (index) => () => _animateMoveOneBall(
                ballFrameA,
                ballFrameC,
                aKeys,
                cKeys,
              ),
        ),
      );
    }

    _playAnimation();
  }

  // When some frames are tapped nothing should happen.
  void _doNothing() {
    return;
  }

  void _refreshAnimation() {
    if (ballAnimator.isAnimating) return;

    setState(() {
      widget.resetNumbers();
      widget.showBackButton = false;
      animationQueue = [];
      initList();
    });

    confettiWidget.stopConfetti();
  }

  void _playAnimation() {
    if (ballAnimator.isAnimating) return;

    // start animation
    if (animationQueue.isNotEmpty) {
      var func = animationQueue.removeAt(0);
      func();
    }
  }

  bool _shouldClickA() {
    return _shouldShowSecondSet() && ballFrameA.isNotEmpty;
  }

  bool _shouldClickZ() {
    return false;
  }

  bool _shouldClickY() {
    return !ballAnimator.isAnimating && ballFrameY.isNotEmpty;
  }

  bool _shouldClickX() {
    return !ballAnimator.isAnimating &&
        ballFrameX.isNotEmpty &&
        ballFrameX.last.color == Colors.green;
  }

  bool _shouldShowSecondSet() {
    return ballFrameZ.length == widget.startX;
  }

  Widget _createSumNumber(
    int x,
    int y,
    Color textColor,
    double fontSize,
    double numberMargin,
  ) {
    double borderWidth = numberMargin;
    return Container(
      margin: EdgeInsets.only(right: numberMargin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: borderWidth),
        ),
      ),
      child: _createNumber(
        (x + y == 0) && widget.startX - widget.startY != 0 ? "=X" : "=${x + y}",
        fontSize,
        textColor,
        true,
      ),
    );
  }

  Widget _createNumber(
    String num,
    double fontSize,
    Color textColor,
    bool hasSign,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: hasSign
          ? [
              Text(
                num[0],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                num.substring(1).trim(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.right,
              )
            ]
          : [
              Text(
                num,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.right,
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var numberFontSize = screenWidth * 0.07;
    double numberMargin = numberFontSize / 7;
    final buttonSize = MediaQuery.of(context).size.height * 0.15;
    final topButtonSize = MediaQuery.of(context).size.height * 0.05;
    final shouldClickIconSize = buttonSize * 0.35;
    var frameSpacer = const SizedBox(height: 3);
    var bigFrameSpacer = const SizedBox(height: 3 * 9);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget._originalStartX} - ${widget._originalStartY}',
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 40),
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${widget.startX}',
                        style: TextStyle(
                          fontSize: numberFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '-',
                        style: TextStyle(
                          fontSize: numberFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${widget.startY}',
                        style: TextStyle(
                          fontSize: numberFontSize,
                          fontWeight: FontWeight.bold,
                          color: colorX,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '=',
                        style: TextStyle(
                          fontSize: numberFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'X',
                        style: TextStyle(
                          fontSize: numberFontSize,
                          fontWeight: FontWeight.bold,
                          color: colorY,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]),

                    Row(
                      children: [
                        InkWell(
                          child: SummationFrame(
                            ballFrame: ballFrameX,
                            numOfTransparentBalls: 0,
                            transparentBallColor: colorY,
                            nRows: 2,
                            keys: xKeys,
                            shouldClick: _shouldClickX(),
                            shouldClickIconSize: shouldClickIconSize,
                          ),
                          onTap: () => _ballFrameXTapFunction(),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: numberMargin),
                            child: _createNumber(
                              (ballFrameZ.length == widget.startX)
                                  ? (widget.startX - widget.startY).toString()
                                  : "X",
                              numberFontSize,
                              colorY,
                              false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          child: SummationFrame(
                            ballFrame: ballFrameY,
                            numOfTransparentBalls: widget.startY,
                            transparentBallColor: colorY,
                            nRows: frameRows,
                            keys: yKeys,
                            shouldClick: _shouldClickY(),
                            shouldClickIconSize: shouldClickIconSize,
                          ),
                          onTap: () => _ballFrameYTapFunction(),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: numberMargin),
                            child: _createNumber(
                              '+${widget.startY}',
                              numberFontSize,
                              colorX,
                              true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          child: SummationFrame(
                            ballFrame: ballFrameZ,
                            numOfTransparentBalls: widget.startX,
                            transparentBallColor: Colors.black,
                            nRows: frameRows,
                            keys: zKeys,
                            shouldClick: _shouldClickZ(),
                            shouldClickIconSize: shouldClickIconSize,
                          ),
                          onTap: () => _ballFrameZTapFunction(),
                        ),
                        Expanded(
                          child: _createSumNumber(
                            widget.startX,
                            0,
                            Colors.black,
                            numberFontSize,
                            numberMargin,
                          ),
                        ),
                      ],
                    ),
                    bigFrameSpacer,

                    AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: _shouldShowSecondSet() ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Row(
                        children: [
                          InkWell(
                            child: SummationFrame(
                              ballFrame: ballFrameA,
                              numOfTransparentBalls:
                                  widget.startX - widget.startY,
                              numOfOtherColorTransparentBalls: widget.startY,
                              transparentBallColor: colorY,
                              nRows: frameRows,
                              keys: aKeys,
                              shouldClick: _shouldClickA(),
                              shouldClickIconSize: shouldClickIconSize,
                            ),
                            onTap: () => _ballFrameATapFunction(),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: numberMargin),
                              child: _createNumber(widget.startX.toString(),
                                  numberFontSize, Colors.black, false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Used to add a very slight spacing between the frames
                    frameSpacer,
                    AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: _shouldShowSecondSet() ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Row(
                        children: [
                          InkWell(
                            child: SummationFrame(
                              ballFrame: ballFrameB,
                              numOfTransparentBalls: widget.startY,
                              transparentBallColor: colorX,
                              nRows: frameRows,
                              keys: bKeys,
                              shouldClick: false,
                              shouldClickIconSize: shouldClickIconSize,
                            ),
                            onTap: () => _doNothing(),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: numberMargin),
                              child: _createNumber('-${widget.startY}',
                                  numberFontSize, colorX, true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: _shouldShowSecondSet() ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Row(
                        children: [
                          InkWell(
                            child: SummationFrame(
                              ballFrame: ballFrameC,
                              numOfTransparentBalls:
                                  widget.startX - widget.startY,
                              transparentBallColor: colorY,
                              nRows: frameRows,
                              keys: cKeys,
                              shouldClick: false,
                              shouldClickIconSize: shouldClickIconSize,
                            ),
                            onTap: () => _doNothing(),
                          ),
                          Expanded(
                            child: _createSumNumber(
                              ballFrameC.length == widget.startX - widget.startY
                                  ? widget.startX - widget.startY
                                  : 0,
                              0,
                              colorY,
                              numberFontSize,
                              numberMargin,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GlowingIconButton(
                Icons.autorenew_rounded,
                iconSize: topButtonSize,
                playAnimationHandle: _refreshAnimation,
                animate: false,
                addedGlowEndRadius: topButtonSize * 0.45,
              ),
            ),
          ),
          if (widget.showBackButton)
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedBackButton(
                buttonSize: buttonSize,
              ),
            ),
          ballAnimator,
          Container(
            alignment: Alignment.topCenter,
            child: confettiWidget,
          ),
        ],
      ),
    );
  }
}

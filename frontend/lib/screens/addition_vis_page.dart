import 'package:flutter/material.dart';

import 'package:olle_app/widgets/number_ball.dart';
import 'package:olle_app/widgets/summation_frame.dart';
import 'package:olle_app/widgets/glowing_icon_button.dart';
import 'package:olle_app/widgets/elevated_back_button.dart';
import 'package:olle_app/widgets/animated_child_positioned.dart';
import 'package:olle_app/widgets/confetti.dart';
import 'package:olle_app/models/addition_strategy.dart';

/// Represents a way to visualize an addition question
///
/// [startX] and [startY] are the values getting added together
///
/// [strategy] represents what way the question should be visualized
// ignore: must_be_immutable
class AdditionVisPage extends StatefulWidget {
  late int _originalStartX;
  late int _originalStartY;

  int startX;
  int startY;
  int startZ = 0;

  AdditionStrategy strategy;
  // status of the visualization (True means the visualization is done)
  bool showBackButton = false;
  late AdditionStrategy originalStrategy;

  AdditionVisPage({
    super.key,
    required this.startX,
    required this.startY,
    this.strategy = AdditionStrategy.raknaUpp,
  }) {
    _originalStartX = startX;
    _originalStartY = startY;
    originalStrategy = strategy;
  }

  void resetNumbers() {
    startX = _originalStartX;
    startY = _originalStartY;
    strategy = originalStrategy;
  }

  @override
  State<AdditionVisPage> createState() => _AdditionVisPageState();
}

/// Creates the actual visualization which consists of 3 ballframes:
/// x, y, and z. X and Y together represent the question and Z represents the answer.
/// ballframes consist of 20 slots where [NumberBall] objects can be stored.
/// [NumberBall] objects can be moved between ballframes. This leaves behind an
/// empty slot with a slight coloration to indicate that a ball has been there previously.
/// These transparent balls can be updated and removed at will via [_updateTransparentBalls].
/// [animationLeftOffset] and [animationTopOffset] are used to store coordinates used in the animations.
/// [xKeys], [yKeys] and [zKeys] are used to create Renderboxes for the animations.
/// [ballFrameX] is used to store the [NumberBall] corresponding to the first part of the question
/// [ballFrameY] is used to store the [NumberBall] corresponding to the second part of the question
/// [ballFrameZ] is used to store the result of the question.
class _AdditionVisPageState extends State<AdditionVisPage> {
  late double animationLeftOffset = 0;
  late double animationTopOffset = 0;

  List<GlobalKey> xKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> yKeys = List.generate(20, (index) => GlobalKey());
  List<GlobalKey> zKeys = List.generate(20, (index) => GlobalKey());

  // Stores the original ballframe in case it's needed after it gets changed.
  late List<NumberBall> originalBallFrameX;
  late List<NumberBall> originalBallFrameY;

  late List<NumberBall> ballFrameX;
  late List<NumberBall> ballFrameY;
  late List<NumberBall> ballFrameZ;

  // Used to create text to display the reasoning
  late double numberFontSize;

  // Used to display text at the bottom of the screen that explains the math behind the visualization.
  // only used in some strategies.
  List<Widget> coloredTextList = [];

  //TODO: change to Theme.of(context)...
  static const Color colorX = Colors.green;
  static const Color colorY = Colors.amber;
  static const frameRows = 2;
  static const ballsPerRow = 20 ~/ frameRows;

  // Used in the strategy tiokompisar. Stores the amount of squares to highlight.
  int remainderToTenX = 0;
  int remainderToTenY = 0;

  // The animator for the page as well as various variables used to create animations.
  late AnimatedChildPositioned ballAnimator;
  bool animationMovingFromX = true;
  bool animationMovingToZ = false;
  bool shouldReplaceBall = false;
  late NumberBall ballBeingAnimated = const NumberBall(
    number: -1,
    color: Colors.black,
    ballsPerRow: ballsPerRow,
  );
  // Used when we want to replace a ball with another instead of removing.
  late NumberBall replaceBall = const NumberBall(
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

  // Generates the list of balls based on strategy and numbers.
  void initList() {
    // ballFrameZ is the result and is always empty at the start.
    ballFrameZ = [];
    switch (widget.strategy) {
      case AdditionStrategy.dubblar:
        generateDubblarList();
        break;

      case AdditionStrategy.nastanDubblar1:
        generateNastanDubblar1List();
        break;

      case AdditionStrategy.nastanDubblar2:
        generateNastanDubblar2List();
        break;

      case AdditionStrategy.okand:
        generateOkandList();
        break;

      case AdditionStrategy.tiokompisar:
        // Can only be used if they sum to at least 10 else we use the default
        if (widget.startX + widget.startY >= 10) {
          generateTiokompisarList();
          break;
        }
        continue defaultCase;
      case AdditionStrategy.raknaUpp:
      case AdditionStrategy.sandbox:
      // Lets tiokompisar move here if the numbers do not sum to at least 10
      defaultCase:
      default:
        generateSandboxList();
        break;
    }
    originalBallFrameX = ballFrameX.toList();
    originalBallFrameY = ballFrameY.toList();
  }

  // Generates the list for the okand strategy. Adds the startX value to ballFrameX
  void generateOkandList() {
    if (widget.startX == 0 && widget.startY == 0) {
      widget.showBackButton = true;
      confettiWidget.playConfetti();
    }
    ballFrameX = List.generate(
      widget.startX,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
      growable: true,
    );
    if (widget.startX == 0) {
      ballFrameY = List.generate(
        1,
        (index) => NumberBall(
          number: index + 1,
          color: colorY,
          ballsPerRow: ballsPerRow,
        ),
        growable: true,
      );
    } else {
      ballFrameY = [];
    }

    ballFrameZ = [];
  }

  // Generates two lists where the last balls in each have different colors to the rest
  void generateDubblarList() {
    ballFrameX = List.generate(
      widget.startX - 1,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
    );
    ballFrameX.add(
      NumberBall(
        number: widget.startX,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
    );
    ballFrameY = List.generate(
      widget.startY - 1,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
    );
    ballFrameY.add(
      NumberBall(
        number: widget.startY,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
    );
  }

  // generates two lists of balls with the same color. The last ball in the longer list is a different color.
  void generateNastanDubblar1List() {
    ballFrameX = List.generate(
      widget.startX,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
    );
    ballFrameY = List.generate(
      widget.startY,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
    );

    // Set the last ball in the largest row to the other color
    if (ballFrameX.length > ballFrameY.length) {
      ballFrameX.last = NumberBall(
        number: widget.startX,
        color: colorY,
        ballsPerRow: ballsPerRow,
      );
    } else {
      ballFrameY.last = NumberBall(
        number: widget.startY,
        color: colorY,
        ballsPerRow: ballsPerRow,
      );
    }
  }

  // Generates two lists of balls. There should be an equal amount of balls spread between the two colors.
  void generateNastanDubblar2List() {
    ballFrameX = List.generate(
      widget.startX,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
    );
    ballFrameY = List.generate(
      widget.startY,
      (index) => NumberBall(
        number: index + 1,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
    );
    // We want the amount of colorX balls to be equal to the amount of colorY balls.
    int numberOfBallsToChange =
        (((ballFrameX.length - ballFrameY.length).abs()) ~/ 2);
    // Sets the last balls to be moved to the other ballFrame to that ballframes color
    if (ballFrameX.length > ballFrameY.length) {
      // Iterate over the last `numberOfBallsToChange` balls in ballFrameX
      for (int i = ballFrameX.length - 1;
          i >= ballFrameX.length - numberOfBallsToChange;
          i--) {
        ballFrameX[i] = NumberBall(
          number: ballFrameX[i].number,
          color: colorY,
          ballsPerRow: ballsPerRow,
        );
      }
    } else {
      // Iterate over the last `numberOfBallsToChange` balls in ballFrameY
      for (int i = ballFrameY.length - 1;
          i >= ballFrameY.length - numberOfBallsToChange;
          i--) {
        ballFrameY[i] = NumberBall(
          number: ballFrameY[i].number,
          color: colorX,
          ballsPerRow: ballsPerRow,
        );
      }
    }
  }

  // Generates a list of balls where the shorter list has some highlighted balls.
  // Also saves remainderToTen to be used later when drawing the ballFrames.
  void generateTiokompisarList() {
    remainderToTenX = 10 - widget.startX;
    remainderToTenY = 10 - widget.startY;
    // Only keeps the smaller remainderToTen
    if (remainderToTenX <= remainderToTenY) {
      remainderToTenY = 0;
    } else if (remainderToTenX > remainderToTenY) {
      remainderToTenX = 0;
    }
    ballFrameX = List.generate(
      widget.startX - remainderToTenY,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
      growable: true,
    );
    // The last few balls in frame drawn with a colored background
    if (remainderToTenY > 0) {
      for (int i = 1; i <= remainderToTenY; i++) {
        ballFrameX.add(
          NumberBall(
            number: widget.startX - remainderToTenY + i,
            color: colorX,
            ballsPerRow: ballsPerRow,
            backgroundColor: colorX,
          ),
        );
      }
    }
    ballFrameY = List.generate(
      widget.startY - remainderToTenX,
      (index) => NumberBall(
        number: index + 1,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
    );
    // The last few balls in frame drawn with a colored background
    if (remainderToTenX > 0) {
      for (int i = 1; i <= remainderToTenX; i++) {
        ballFrameY.add(
          NumberBall(
            number: widget.startY - remainderToTenX + i,
            color: colorY,
            ballsPerRow: ballsPerRow,
            backgroundColor: colorY, //Hardcoded. Could be changed.
          ),
        );
      }
    }
  }

  // Generates a default list of two balls with two different colors.
  void generateSandboxList() {
    ballFrameX = List.generate(
      widget.startX,
      (index) => NumberBall(
        number: index + 1,
        color: colorX,
        ballsPerRow: ballsPerRow,
      ),
      growable: true,
    );

    ballFrameY = List.generate(
      widget.startY,
      (index) => NumberBall(
        number: index + 1,
        color: colorY,
        ballsPerRow: ballsPerRow,
      ),
    );
  }

  // Generates the list of text widgets used to display math at the bottom of the screen.
  // Creates the initial text that is to be displayed before anything is pressed.
  // Only used for some strategies.
  // coloredTextList should probably have been its own widget.
  void generateColoredTextList() {
    // Each case creates the initial text for a specific strategy.
    // Needs to be multiple text widgets as they need to change color.
    switch (widget.strategy) {
      case AdditionStrategy.tiokompisar:
        int maxValue =
            widget.startX > widget.startY ? widget.startX : widget.startY;
        int difference = 10 - maxValue;
        coloredTextList = [
          Text(
            '${widget.startX}+${widget.startY}=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.startX > widget.startY ? '${widget.startX}' : '$difference',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.startY > widget.startX ? '${widget.startY}' : '$difference',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.startX > widget.startY
                ? '${widget.startY - difference}'
                : '${widget.startX - difference}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: widget.startX > widget.startY ? colorY : colorX,
            ),
            textAlign: TextAlign.center,
          ),
        ];
      case AdditionStrategy.nastanDubblar2:
        int minValue =
            widget.startX > widget.startY ? widget.startY : widget.startX;
        int difference = (((widget.startX - widget.startY).abs()) ~/ 2);
        coloredTextList = [
          Text(
            '${widget.startX}+${widget.startY}=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.startX > widget.startY
                ? '${widget.startX - difference}'
                : '$minValue',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.startY > widget.startX
                ? '${widget.startY - difference}'
                : '$minValue',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '$difference',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: widget.startX > widget.startY ? colorY : colorX,
            ),
            textAlign: TextAlign.center,
          ),
        ];
      case AdditionStrategy.nastanDubblar1:
        int minValue =
            widget.startX > widget.startY ? widget.startY : widget.startX;
        coloredTextList = [
          Text(
            '${widget.startX}+${widget.startY}=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '$minValue',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '$minValue',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ),
        ];
      case AdditionStrategy.dubblar:
        coloredTextList = [
          Text(
            '${widget.startX}+${widget.startY}=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${widget.startX - 1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${widget.startX - 1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ),
        ];
      default:
        break;
    }
  }

  // Called when the animation completes. Doesn't work unless more than one animation has played.
  void onAnimationComplete() {
    if (animationMovingToZ) {
      ballFrameZ.add(ballBeingAnimated);
    } else {
      if (animationMovingFromX) {
        ballFrameY.add(ballBeingAnimated);
      } else {
        ballFrameX.add(ballBeingAnimated);
      }
    }
    if (widget.strategy == AdditionStrategy.okand &&
        ballFrameZ.length != widget.startY &&
        ballFrameX.isEmpty) {
      ballFrameY.add(
        NumberBall(
          number: ballFrameY.length + 1,
          color: colorY,
          ballsPerRow: ballsPerRow,
        ),
      );
    }
    if (animationQueue.isNotEmpty) {
      var func = animationQueue.removeAt(0);
      func();
    } else {
      // Adds new text at the bottom if there should be new text.
      addTextToColoredTextList();
      // The user has reached a state where it is not expected to do anything.
      // A backbutton is shown to indicate completion.
      if (widget.strategy == AdditionStrategy.okand &&
          ballFrameZ.length == widget.startY) {
        widget.showBackButton = true;
        confettiWidget.playConfetti();
      } else if (ballFrameZ.length ==
              (originalBallFrameX.length + originalBallFrameY.length) &&
          widget.strategy != AdditionStrategy.okand) {
        widget.showBackButton = true;
        confettiWidget.playConfetti();
        // The user can do what it wants in sandbox mode,
        // backbutton should not show.
      } else if (widget.strategy == AdditionStrategy.sandbox) {
        widget.showBackButton = false;
      }
    }

    // Empty setState used to rebuild the screen so that the ball that was just
    // animated is shown to have "landed" in place
    // (otherwise the position on the screen will be empty)
    setState(() {});
  }

  // Updates the slightly colored balls left behind after a ball has moved.
  void _updateTransparentBalls() {
    widget.startX = ballFrameX.length;
    widget.startY = ballFrameY.length;
    widget.startZ = ballFrameZ.length;
    // Extra place to check for completion since it isn't checked elsewhere if only one ball is moved.
    if (widget.strategy == AdditionStrategy.okand &&
        ballFrameZ.length == widget.startY) {
      widget.showBackButton = true;
      confettiWidget.playConfetti();
    } else if (ballFrameZ.length ==
            (originalBallFrameX.length + originalBallFrameY.length) &&
        widget.strategy != AdditionStrategy.okand) {
      widget.showBackButton = true;
      confettiWidget.playConfetti();
    }
  }

  // Get an offset that represents the coordinates of one NumberBall or empty slot in ballFrameZ
  // To be used in moveOneBallToZ
  Offset _getZOffset(int index) {
    late RenderBox renderBox;
    renderBox = zKeys[index].currentContext?.findRenderObject() as RenderBox;

    Offset pixelOffset = renderBox.localToGlobal(Offset.zero);

    return Offset(pixelOffset.dx,
        pixelOffset.dy - MediaQuery.of(context).padding.top - kToolbarHeight);
  }

  // Get an offset that represents the coordinates of one NumberBall or empty slot in either ballFrameX or ballFrameY
  // To be used in moveOneBall
  Offset _getOffset(bool moveFromX, int index) {
    late RenderBox renderBox;
    if (moveFromX) {
      renderBox = xKeys[index].currentContext?.findRenderObject() as RenderBox;
    } else {
      renderBox = yKeys[index].currentContext?.findRenderObject() as RenderBox;
    }

    Offset pixelOffset = renderBox.localToGlobal(Offset.zero);

    return Offset(pixelOffset.dx,
        pixelOffset.dy - MediaQuery.of(context).padding.top - kToolbarHeight);
  }

  // Returns an animation to the ballAnimator
  void _animateMoveOneBall(bool shouldMoveFromX,
      {int? ballToMoveIndex, bool? shouldMoveFromZInstead}) {
    _moveOneBall(
      shouldMoveFromX: shouldMoveFromX,
      ballToMoveIndex: ballToMoveIndex,
      shouldMoveFromZInstead: shouldMoveFromZInstead,
    );
  }

  // Returns an animation to the ballAnimator
  void _animateMoveOneBallToZ(
      bool shouldMoveFromX, bool shouldUpdateTransparent,
      {int? ballToMoveIndex}) {
    _moveOneBallToZ(
      shouldMoveFromX: shouldMoveFromX,
      ballToMoveIndex: ballToMoveIndex,
    );
    if (shouldUpdateTransparent) {
      _updateTransparentBalls();
    }
  }

  // Moves one ball frome ballFrameX or ballFrameY to ballFrameZ
  void _moveOneBallToZ({
    required bool shouldMoveFromX,
    int? ballToMoveIndex,
  }) {
    animationMovingFromX = shouldMoveFromX;
    // Used when updating which ball has been moved.
    animationMovingToZ = true;
    // The index of the ball that should move.
    int startIndex;

    // Default to always moving the last ball in the list if no value for index is given
    if (ballToMoveIndex == null) {
      startIndex =
          shouldMoveFromX ? ballFrameX.length - 1 : ballFrameY.length - 1;
    } else {
      startIndex = ballToMoveIndex;
    }

    // Always moves to the first empty slot in ballFrameZ
    var endIndex = ballFrameZ.length;

    // Get the offsets(coordinates) that the animation should move between.
    Offset startOffset = _getOffset(shouldMoveFromX, startIndex);
    Offset endOffset = _getZOffset(endIndex);

    if (shouldReplaceBall) {
      ballBeingAnimated =
          shouldMoveFromX ? ballFrameX[startIndex] : ballFrameY[startIndex];

      NumberBall replaceBall = NumberBall(
        number: ballBeingAnimated.number,
        color: ballBeingAnimated.color.withOpacity(0.3),
        ballsPerRow: ballsPerRow,
      );
      if (shouldMoveFromX) {
        ballFrameX[startIndex] = replaceBall;
      } else {
        ballFrameY[startIndex] = replaceBall;
      }
    } else {
      ballBeingAnimated = shouldMoveFromX
          ? ballFrameX.removeAt(startIndex)
          : ballFrameY.removeAt(startIndex);
    }

    ballBeingAnimated = NumberBall(
      number: endIndex + 1,
      color: ballBeingAnimated.color,
      ballsPerRow: ballsPerRow,
    );

    var ballRowToChange = shouldMoveFromX ? ballFrameX : ballFrameY;
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

  // Moves one ball from ballFrameY to ballFrameX or vice versa
  void _moveOneBall({
    required bool shouldMoveFromX,
    int? ballToMoveIndex,
    bool? shouldMoveFromZInstead,
  }) {
    animationMovingFromX = shouldMoveFromX;
    widget.showBackButton = false;
    int startIndex;
    // if null we should not move to Z instead
    shouldMoveFromZInstead ??= false;

    // Default to always moving the last ball in the list if no value for index is given
    if (ballToMoveIndex == null) {
      startIndex =
          shouldMoveFromX ? ballFrameX.length - 1 : ballFrameY.length - 1;
      if (shouldMoveFromZInstead) {
        startIndex = ballFrameZ.length - 1;
      }
    } else {
      startIndex = ballToMoveIndex;
    }

    // Endindex is always the first empty slot in the ballFrame that we are moving to.
    var endIndex = shouldMoveFromX ? ballFrameY.length : ballFrameX.length;

    // Get the coordinates of the ball we sohould move.
    Offset startOffset = shouldMoveFromZInstead
        ? _getZOffset(startIndex)
        : _getOffset(shouldMoveFromX, startIndex);
    Offset endOffset = _getOffset(!shouldMoveFromX, endIndex);

    // Remove the ball that should be moved.
    if (shouldMoveFromZInstead) {
      ballBeingAnimated = ballFrameZ.removeAt(startIndex);
    } else {
      ballBeingAnimated = shouldMoveFromX
          ? ballFrameX.removeAt(startIndex)
          : ballFrameY.removeAt(startIndex);
    }

    ballBeingAnimated = NumberBall(
      number: endIndex + 1,
      color: ballBeingAnimated.color,
      ballsPerRow: ballsPerRow,
    );

    var ballRowToChange = shouldMoveFromX ? ballFrameX : ballFrameY;
    ballRowToChange = shouldMoveFromZInstead ? ballFrameZ : ballRowToChange;
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

  /// what happens when ballFrameZ is tapped. Only used in [AdditionStrategy.okand]
  /// Moves all appropriate balls to [ballFrameY]
  void _ballFrameZTapFunction() {
    return;
  }

  // Adds new text to coloredTextList which displays at the bottom.
  // Based on strategy and where the balls are in the frames.
  void addTextToColoredTextList() {
    switch (widget.strategy) {
      case AdditionStrategy.tiokompisar:
        if (ballFrameZ.length == 10) {
          coloredTextList.add(Text(
            '=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '${10}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            widget.startX > widget.startY
                ? '${widget.startY - (10 - (widget.startX))}'
                : '${widget.startX - (10 - (widget.startY))}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: widget.startX > widget.startY ? colorY : colorX,
            ),
            textAlign: TextAlign.center,
          ));
        } else if (ballFrameZ.length == widget.startX + widget.startY) {
          coloredTextList.add(Text(
            '=${widget.startY + widget.startX}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
        }
        break;
      case AdditionStrategy.nastanDubblar1:
        if (ballFrameZ.length == widget.startX + widget.startY - 1) {
          coloredTextList.add(Text(
            '=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '${widget.startX + widget.startY - 1}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '1',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ));
        } else if (ballFrameZ.length == widget.startX + widget.startY) {
          coloredTextList.add(Text(
            '=${widget.startY + widget.startX}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
        }
        break;
      case AdditionStrategy.nastanDubblar2:
        if (ballFrameX.length == ballFrameY.length &&
            ballFrameX.isNotEmpty &&
            ballFrameY.isNotEmpty) {
          coloredTextList.add(Text(
            '=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '${(widget.startX + widget.startY) ~/ 2}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '${(widget.startX + widget.startY) ~/ 2}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ));
        } else if (ballFrameX.isEmpty && ballFrameY.isEmpty) {
          coloredTextList.add(Text(
            '=${widget.startY + widget.startX}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
        }
        break;
      case AdditionStrategy.dubblar:
        if (ballFrameZ.length == widget.startX + widget.startY - 2) {
          coloredTextList.add(Text(
            '=',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '${widget.startX + widget.startY - 2}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorX,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '+',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
          coloredTextList.add(Text(
            '2',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: colorY,
            ),
            textAlign: TextAlign.center,
          ));
        }
        if (ballFrameZ.length == widget.startX + widget.startY) {
          coloredTextList.add(Text(
            '=${widget.startY + widget.startX}',
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
        }
        break;
      default:
        break;
    }
  }

  // The logic for which numbers should move once a frame is clicked
  // Based on strategy and amount of balls in the frames
  void _moveNumber(bool shouldMoveFromX) {
    shouldReplaceBall = false;
    if (shouldMoveFromX && (ballFrameX.isEmpty)) {
      return;
    }
    if (!shouldMoveFromX && (ballFrameY.isEmpty)) {
      return;
    }
    if (widget.showBackButton) {
      return;
    }
    if (ballAnimator.isAnimating) return;

    switch (widget.strategy) {
      // Moves all balls to Z based on clicked frame.
      case AdditionStrategy.raknaUpp:
        animationQueue.addAll(
          List.generate(
            shouldMoveFromX ? ballFrameX.length : ballFrameY.length,
            (index) => () => _animateMoveOneBallToZ(
                  shouldMoveFromX,
                  false,
                ),
          ),
        );
        _playAnimation();
        break;
      // Moves everything but one ball to Z. Then moves that single ball.
      case AdditionStrategy.nastanDubblar1:
        bool shouldSaveOneInX = ballFrameX.length > ballFrameY.length;
        if (ballFrameX[0].color == colorX) {
          shouldReplaceBall = true;
          animationQueue.addAll(
            List.generate(
              shouldSaveOneInX ? ballFrameX.length - 1 : ballFrameX.length,
              (index) => () => _animateMoveOneBallToZ(
                    true,
                    false,
                    ballToMoveIndex: index,
                  ),
            ),
          );
          animationQueue.addAll(
            List.generate(
              shouldSaveOneInX ? ballFrameY.length : ballFrameY.length - 1,
              (index) => () => _animateMoveOneBallToZ(
                    false,
                    false,
                    ballToMoveIndex: index,
                  ),
            ),
          );
        } else {
          animationQueue.addAll(
            List.generate(
              1,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                    ballToMoveIndex: shouldMoveFromX
                        ? ballFrameX.length - 1
                        : ballFrameY.length - 1,
                  ),
            ),
          );
        }
        _playAnimation();
      // Makes both frames have the same length. Then moves everything to Z
      case AdditionStrategy.nastanDubblar2:
        int ballFrameDifference = ballFrameX.length - ballFrameY.length;
        int ballsToMoveOver = (((ballFrameDifference).abs()) ~/ 2);
        if (ballFrameX.length != ballFrameY.length &&
            ballFrameX.isNotEmpty &&
            ballFrameY.isNotEmpty) {
          if (ballFrameDifference != 0) {
            if (ballFrameX.length > ballFrameY.length) {
              animationQueue.addAll(
                List.generate(
                  ballsToMoveOver,
                  (index) => () => _animateMoveOneBall(
                        true,
                      ),
                ),
              );
            } else if (ballFrameY.length > ballFrameX.length) {
              animationQueue.addAll(
                List.generate(
                  ballsToMoveOver,
                  (index) => () => _animateMoveOneBall(
                        false,
                      ),
                ),
              );
            }
          }
        } else {
          if (shouldMoveFromX) {
            animationQueue.addAll(
              List.generate(
                ballFrameX.length,
                (index) => () => _animateMoveOneBallToZ(
                      shouldMoveFromX,
                      false,
                    ),
              ),
            );
          } else {
            animationQueue.addAll(
              List.generate(
                ballFrameY.length,
                (index) => () => _animateMoveOneBallToZ(shouldMoveFromX, false),
              ),
            );
          }
        }
        _playAnimation();
        break;
      // Leaves one ball in each frame then moves those individually.
      case AdditionStrategy.dubblar:
        if (shouldMoveFromX && ballFrameX.last.color != colorY ||
            !shouldMoveFromX && ballFrameY.last.color != colorY) {
          return;
        }
        if (ballFrameX[0].color == colorX) {
          shouldReplaceBall = true;
          animationQueue.addAll(
            List.generate(
              ballFrameX.length - 1,
              (index) => () => _animateMoveOneBallToZ(
                    true,
                    false,
                    ballToMoveIndex: index,
                  ),
            ),
          );
          animationQueue.addAll(
            List.generate(
              ballFrameY.length - 1,
              (index) => () => _animateMoveOneBallToZ(
                    false,
                    false,
                    ballToMoveIndex: index,
                  ),
            ),
          );
        } else {
          animationQueue.addAll(
            List.generate(
              1,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                    ballToMoveIndex: shouldMoveFromX
                        ? ballFrameX.length - 1
                        : ballFrameY.length - 1,
                  ),
            ),
          );
        }
        _playAnimation();
        break;
      // Moves everything from the longer ballframe to Z
      // Then moves enough balls to have Z = 10
      // Then moves the rest
      case AdditionStrategy.tiokompisar:
        int ballsToMove = remainderToTenX >= remainderToTenY
            ? remainderToTenX
            : remainderToTenY;

        bool xLongerThanY = ballFrameX.length >= ballFrameY.length;

        if (ballFrameZ.isEmpty) {
          if (xLongerThanY != shouldMoveFromX) {
            return;
          }
          animationQueue.addAll(
            List.generate(
              shouldMoveFromX ? ballFrameX.length : ballFrameY.length,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                  ),
            ),
          );
        } else if (ballFrameZ.length != 10) {
          animationQueue.addAll(
            List.generate(
              ballsToMove,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                  ),
            ),
          );
        } else {
          animationQueue.addAll(
            List.generate(
              shouldMoveFromX ? ballFrameX.length : ballFrameY.length,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                  ),
            ),
          );
        }
        _playAnimation();
        break;
      // Moves one ball at a time
      case AdditionStrategy.okand:
        if (shouldMoveFromX) {
          animationQueue.addAll(
            List.generate(
              ballFrameX.length,
              (index) => () => _animateMoveOneBallToZ(
                    shouldMoveFromX,
                    false,
                  ),
            ),
          );
        } else {
          shouldReplaceBall = true;
          _moveOneBallToZ(shouldMoveFromX: shouldMoveFromX);
        }

        _playAnimation();
        break;
      case AdditionStrategy.sandbox:
      default:
        _moveOneBallToZ(shouldMoveFromX: shouldMoveFromX);
        break;
    }
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

  // If some very specific conditions are met. shouldHighlight should be true for ballFrameZ
  bool _shouldHighlightZ() {
    return (((ballFrameZ.length >= originalBallFrameX.length &&
                ballFrameX.length != widget.startX) ||
            (ballFrameZ.length >= originalBallFrameY.length &&
                ballFrameY.length != widget.startY)) &&
        widget.strategy == AdditionStrategy.tiokompisar);
  }

  bool _shouldClickZ() {
    return false;
  }

  // If true indicate to user that it should click ballFrameX
  bool _shouldClickX() {
    bool recall =
        !_shouldClickY() && !widget.showBackButton && !ballAnimator.isAnimating;
    return recall;
  }

  // If true indicate to user that it should click ballFrameY
  bool _shouldClickY() {
    bool recall = false;
    bool yLargerthanX = ballFrameY.length > ballFrameX.length;
    bool shouldReturn = widget.showBackButton;
    if (ballAnimator.isAnimating) {
      return recall;
    }
    switch (widget.strategy) {
      case AdditionStrategy.okand:
        recall = ballFrameX.isEmpty && ballFrameZ.length != widget.startY;
      case AdditionStrategy.tiokompisar:
      case AdditionStrategy.raknaUpp:
        recall = yLargerthanX && !shouldReturn;
        break;
      case AdditionStrategy.dubblar:
        recall = animationQueue.isEmpty &&
            ballFrameY.length >= ballFrameX.length &&
            ballFrameZ.length != widget.startX + widget.startY;
        break;
      case AdditionStrategy.nastanDubblar1:
        recall = ballFrameY.length > ballFrameX.length &&
            ballFrameZ.length != widget.startX + widget.startY;
        break;
      case AdditionStrategy.nastanDubblar2:
        recall = ballFrameY.length > ballFrameX.length;
        break;
      case AdditionStrategy.sandbox:
        recall = true;
        break;
      default:
        break;
    }
    return recall;
  }

  Widget _createSumNumber(
    int x,
    int y,
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
          (x + y == 0 && widget.startX + widget.startY != 0)
              ? "=X"
              : "=${x + y}",
          fontSize,
          Colors.black),
    );
  }

  Widget _createNumber(
    String num,
    double fontSize,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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

  // Gets the number that should be showed as the sum
  int _getNumberToSum() {
    int result = (ballFrameZ.length ==
            originalBallFrameX.length + originalBallFrameY.length)
        ? ballFrameZ.length
        : 0;
    if (widget.strategy == AdditionStrategy.okand) {
      result = widget.startY;
    }
    return result;
  }

  // Gets the value to be showed next to ballFrameY
  String _getYNumber() {
    if (widget.strategy != AdditionStrategy.okand) {
      return widget.startY.toString();
    } else if (widget.strategy == AdditionStrategy.okand &&
        ((ballFrameZ.length != widget.startY) || ballAnimator.isAnimating)) {
      return 'Y';
    } else {
      return (widget.startY - widget.startX).toString();
    }
  }

  int _numOfTransparentBallsY() {
    switch (widget.strategy) {
      case AdditionStrategy.nastanDubblar1:
        if (widget.startY > widget.startX) {
          return widget.startY - 1;
        } else {
          return widget.startY;
        }
      case AdditionStrategy.nastanDubblar2:
        if (widget.startY > widget.startX) {
          return widget.startX + ((widget.startY - widget.startX) ~/ 2);
        } else {
          return widget.startY;
        }
      case AdditionStrategy.okand:
        return 0;
      default:
        return widget.startY;
    }
  }

  int _numOfOtherColoredTransparentBallsY() {
    switch (widget.strategy) {
      case AdditionStrategy.nastanDubblar1:
        if (widget.startY > widget.startX) {
          return 1;
        } else {
          return 0;
        }
      case AdditionStrategy.nastanDubblar2:
        if (widget.startY > widget.startX) {
          return (widget.startY - widget.startX) ~/ 2;
        } else {
          return 0;
        }
      default:
        return 0;
    }
  }

  int _numOfTransparentBallsX() {
    switch (widget.strategy) {
      case AdditionStrategy.nastanDubblar1:
        if (widget.startX > widget.startY) {
          return widget.startX - 1;
        } else {
          return widget.startX;
        }
      case AdditionStrategy.nastanDubblar2:
        if (widget.startX > widget.startY) {
          return widget.startY + ((widget.startX - widget.startY) ~/ 2);
        } else {
          return widget.startX;
        }
      default:
        return widget.startX;
    }
  }

  int _numOfOtherColoredTransparentBallsX() {
    switch (widget.strategy) {
      case AdditionStrategy.nastanDubblar1:
        if (widget.startX > widget.startY) {
          return 1;
        } else {
          return 0;
        }
      case AdditionStrategy.nastanDubblar2:
        if (widget.startX > widget.startY) {
          return (widget.startX - widget.startY) ~/ 2;
        } else {
          return 0;
        }
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    numberFontSize = screenWidth * 0.07;
    double numberMargin = numberFontSize / 7;
    final buttonSize = MediaQuery.of(context).size.height * 0.15;
    final topButtonSize = MediaQuery.of(context).size.height * 0.05;
    final shouldClickIconSize = buttonSize * 0.35;
    //Called here as we need access to fontsizes when creating this list.
    if (coloredTextList.isEmpty) {
      generateColoredTextList();
    }

    // click variables are used to show a hand on the summation frames.
    var clickX = _shouldClickX() && widget.strategy != AdditionStrategy.sandbox;
    var clickY = _shouldClickY() && widget.strategy != AdditionStrategy.sandbox;
    var clickZ = _shouldClickZ();

    var frameSpacer = const SizedBox(height: 3);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.strategy == AdditionStrategy.okand
              ? '${widget._originalStartX} + Y = ${widget._originalStartY}'
              : '${widget._originalStartX} + ${widget._originalStartY}',
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          child: SummationFrame(
                            ballFrame: ballFrameX,
                            numOfTransparentBalls: _numOfTransparentBallsX(),
                            transparentBallColor:
                                widget.strategy == AdditionStrategy.dubblar
                                    ? colorY
                                    : colorX,
                            nRows: frameRows,
                            numOfOtherColorTransparentBalls:
                                _numOfOtherColoredTransparentBallsX(),
                            // Used in tiokompisar
                            shouldHighlight: (widget.strategy ==
                                    AdditionStrategy.tiokompisar &&
                                remainderToTenX != 0 &&
                                ballFrameX.length == originalBallFrameX.length),
                            keys: xKeys,
                            shouldClick: clickX,
                            shouldClickIconSize: shouldClickIconSize,
                          ),
                          onTap: () => _moveNumber(true),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: numberMargin),
                            child: _createNumber(
                              widget.startX.toString(),
                              numberFontSize,
                              widget.strategy == AdditionStrategy.tiokompisar
                                  ? colorX
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Used to add a very sight spacing between the frames
                    frameSpacer,
                    Row(
                      children: [
                        InkWell(
                          child: SummationFrame(
                            ballFrame: ballFrameY,
                            numOfTransparentBalls: _numOfTransparentBallsY(),
                            transparentBallColor: widget.strategy ==
                                    AdditionStrategy.nastanDubblar1
                                ? colorX
                                : colorY,
                            nRows: frameRows,
                            numOfOtherColorTransparentBalls:
                                _numOfOtherColoredTransparentBallsY(),
                            // Used in tiokompisar
                            shouldHighlight: (widget.strategy ==
                                    AdditionStrategy.tiokompisar &&
                                remainderToTenY != 0 &&
                                ballFrameY.length == originalBallFrameY.length),
                            keys: yKeys,
                            shouldClick: clickY,
                            shouldClickIconSize: shouldClickIconSize,
                          ),
                          onTap: () => _moveNumber(false),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: numberMargin),
                            child: _createNumber(
                              '+${_getYNumber()}',
                              numberFontSize,
                              widget.strategy == AdditionStrategy.tiokompisar
                                  ? colorY
                                  : Colors.black,
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
                              numOfTransparentBalls:
                                  widget.strategy == AdditionStrategy.okand
                                      ? widget.startY
                                      : 0,
                              transparentBallColor:
                                  widget.strategy == AdditionStrategy.okand
                                      ? Colors.black
                                      : widget.startX > widget.startY
                                          ? colorX
                                          : colorY,
                              nRows: frameRows,
                              // Used in tiokompisar
                              shouldHighlight: _shouldHighlightZ(),
                              keys: zKeys,
                              shouldClick: clickZ,
                              shouldClickIconSize: shouldClickIconSize,
                            ),
                            onTap: () => _ballFrameZTapFunction()),
                        Expanded(
                          child: _createSumNumber(
                            _getNumberToSum(),
                            0,
                            numberFontSize,
                            numberMargin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: coloredTextList.toList(),
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

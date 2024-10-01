import 'package:flutter/material.dart';
import 'package:olle_app/functions/progress.dart';
import 'package:olle_app/functions/visual_help_router.dart';
import 'package:olle_app/screens/progress_screen.dart';
import 'package:provider/provider.dart';

import 'package:olle_app/functions/practice_session.dart';

/// Contains columns of rows of buttons to form a numpad
class Numpad extends StatelessWidget {
  const Numpad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: NumpadButton(label: "1")),
                  const Expanded(child: NumpadButton(label: "4")),
                  const Expanded(child: NumpadButton(label: "7")),
                  Expanded(
                      child: NumpadButton(
                    label: "C",
                    buttonColor: Theme.of(context).colorScheme.errorContainer,
                    labelColor: Theme.of(context).colorScheme.onErrorContainer,
                  )),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: NumpadButton(label: "2")),
                  Expanded(child: NumpadButton(label: "5")),
                  Expanded(child: NumpadButton(label: "8")),
                  Expanded(child: NumpadButton(label: "0")),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: NumpadButton(label: "3")),
                  Expanded(child: NumpadButton(label: "6")),
                  Expanded(child: NumpadButton(label: "9")),
                  Expanded(
                    child: NumpadButton(
                        label: "<", iconData: Icons.backspace_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(flex: 3, child: EnterButton(label: "=")),
                  Expanded(
                      child: NumpadButton(
                    label: "?",
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    buttonColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Represents a numpad button
///
/// [label] is the label on the key
class NumpadButton extends StatelessWidget {
  const NumpadButton({
    Key? key,
    required this.label,
    this.disabled = false,
    this.iconData,
    this.labelColor,
    this.buttonColor,
  }) : super(key: key);

  final String label;
  final bool disabled;
  final Color? labelColor;
  final Color? buttonColor;
  final IconData? iconData;

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    PracticeSession session = Provider.of<PracticeSession>(context);
    VoidCallback onClickOperand;
    onClickOperand = setOnClick(context);
    var onClickFunction = label == '?'
        ? onClickOperand
        : () {
            session.input.length >= 2 && isNumeric(label)
                ? null
                : session.addInput(label);
          };
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: buttonColor ?? Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
          child: InkWell(
            highlightColor: Colors.white.withOpacity(0.3),
            splashColor: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(1000),
            onTap: disabled ? null : onClickFunction,
            child: Center(
              child: iconData == null
                  ? Text(
                      label,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w400,
                        color: labelColor ??
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : Icon(
                      iconData,
                      color: labelColor ??
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 38,
                    ),
            ),
          ),
        ));
  }

  /// Returns a function [onClickOperand]
  /// depending on the arithmetic operation.
  static VoidCallback setOnClick(BuildContext context) {
    PracticeSession session =
        Provider.of<PracticeSession>(context, listen: false);
    switch (session.operand) {
      case '+':
        return () => Navigator.push(context, AddRoute(session: session));
      case 'p':
        return () => Navigator.push(context, AddyRoute(session: session));
      case '-':
        return () => Navigator.push(context, SubRoute(session: session));
      case '*':
        return () => Navigator.push(context, MulRoute(session: session));
      case 'm':
        return () => Navigator.push(context, MulyRoute(session: session));
      case '/':
        return () => Navigator.push(context, DivRoute(session: session));
      default:
        throw ArgumentError.value(session.operand, 'input', 'Invalid input');
    }
  }
}

/// Represents a part of an enter-button.
///
/// [label] is the label on the key
/// [disabled] decides if the button should be greyed out, disabled
class EnterButton extends StatelessWidget {
  const EnterButton({Key? key, required this.label}) : super(key: key);

  final String label;

  _onTap(BuildContext context) async {
    PracticeSession session =
        Provider.of<PracticeSession>(context, listen: false);
    ProgressModel progressModel =
        Provider.of<ProgressModel>(context, listen: false);

    await session.addInput(label);
    progressModel.setProgress(session: session);
    if (progressModel.progress == 1) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProgressScreen(
            correctAnswersCount: session.correctCounter,
            wrongAnswersCount: session.wrongCounter,
            highestHotstreak: session.hotStreak,
            secondsPlayed: session.timer.toInt() ~/ 1000,
            operand: session.operand,
            previousLevel: session.prevLevel,
            currentLevel: session.level,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    PracticeSession session = Provider.of<PracticeSession>(context);

    return Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
          child: InkWell(
            highlightColor: Colors.white.withOpacity(0.3),
            splashColor: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(1000),
            onTap: session.input.isEmpty
                ? null
                : () {
                    _onTap(context);
                  },
            child: Center(
              child: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 38,
              ),
            ),
          ),
        ));
  }
}

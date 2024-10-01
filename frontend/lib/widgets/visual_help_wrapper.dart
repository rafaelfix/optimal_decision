import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nativelib/nativelib.dart';
import 'package:olle_app/functions/practice_session.dart';

/// This is a wrapper meant to wrap around one of the visualisation pages
/// * [AdditionVisPage]
/// * [SubractionVisPage]
/// * [MultiVisPage]
/// * [DivVisPage]
/// It is only meant to be used if a [PracticeSession] is currently running
///
/// It has two different functions:
/// * If the user pressed the "?" button the wrapper will pause the timer and store the keypresses
/// * If used from an Vis Question it generates a new question after, stores the current one, aswell as above stated.
class VisualHelpWrapper extends StatelessWidget {
  const VisualHelpWrapper(
      {super.key, required this.child, required this.session});

  final Widget child;
  final PracticeSession session;

  void _store() async {
    await Nativelib.call("addKey", ["R"]);
    if (session.question.visualHelp == 'a') {
      await Nativelib.call("saveAnswerToFile");
      await Nativelib.call("storeAnswer");
      session.input = '';
      session.createQuestion();
    }
    session.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print('[Wrapper] PUSH');
    Nativelib.call("addKey", ["?"]);
    session.stopTimer();
    return PopScope(
        onPopInvoked: (didPop) {
          if (kDebugMode) print('[Wrapper] POP');
          _store();
        },
        child: child);
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nativelib/nativelib.dart';
import 'package:olle_app/functions/operator_information.dart';
import 'package:olle_app/functions/practice_session.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/functions/progress.dart';
import 'package:olle_app/functions/visual_help_router.dart';
import 'package:olle_app/widgets/numpad.dart';
import 'package:olle_app/widgets/olle_app_bar.dart';
import 'package:provider/provider.dart';

/// Widget for displaying the practice view
///
/// [title] is the type of operand to be practiced
class PracticePage extends StatelessWidget {
  const PracticePage({Key? key, required this.title}) : super(key: key);
  final String title; // TODO: replace with TaskType

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    double _numpadSize = (_screenSize.width < _screenSize.height / 2)
        ? _screenSize.width
        : _screenSize.height / 2;

    Nativelib.call("gamingTimeStart");
    ProfileModel profileModel = Provider.of<ProfileModel>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => PracticeSession(operand: title)),
        ChangeNotifierProvider(create: (context) => ProgressModel()),
      ],
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          await Nativelib.call("gamingTimeEnd");
          await profileModel.tryUploadSessions();
        },
        child: Scaffold(
          appBar: OlleAppBar(
            selectedProfile:
                Provider.of<ProfileModel>(context).selectedProfile.name,
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  child: ProgressBar(),
                ),
                const Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: PreviousQuestionWidget()),
                      QuestionWidget(),
                    ],
                  ),
                ),
                Divider(
                  indent: 12,
                  endIndent: 12,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                SizedBox(
                    width: _numpadSize,
                    height: _numpadSize,
                    child: const Numpad()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that displays current level, average time and ammount of correct
///
/// Uses provider to access the practice session.
class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProgressModel progressModel = Provider.of<ProgressModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 15,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: progressModel.progress,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }
}

String displayQuestion(Question question, {bool isFirstPart = true}) {
  switch (question.questionType) {
    case "+":
    case "-":
    case "*":
    case "/":
      final unicodeOperator = OperatorHandler.toUnicode[question.questionType];
      return "${question.firstNumber} $unicodeOperator ${question.secondNumber} =";
    case "p":
      final unicodeOperator = OperatorHandler.toUnicode["+"]; // Unicode for "+"
      String firstPart = "${question.firstNumber} $unicodeOperator";
      String secondPart = " = ${question.secondNumber}";
      return isFirstPart ? firstPart : secondPart;
    case "m":
      final unicodeOperator = OperatorHandler.toUnicode["*"]; // Unicode for "*"
      String firstPart = "${question.firstNumber} $unicodeOperator";
      String secondPart = " = ${question.secondNumber}";
      return isFirstPart ? firstPart : secondPart;
    default:
      throw UnsupportedError(
          "Unsupported question type: ${question.questionType}");
  }
}

/// Displays the current question under the history
///
/// Uses provider to access the practice session
class QuestionWidget extends StatelessWidget {
  const QuestionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PracticeSession session = Provider.of<PracticeSession>(context);
    ProgressModel progressModel = Provider.of<ProgressModel>(context);
    if (session.questions.isEmpty) {
      return const ListTile(title: Text('No Question'));
    }

    Question current = session.question;
    if (current.visualHelp == 'a' &&
        !session.question.viewed &&
        progressModel.progress < 1) {
      session.question.viewed = true;

      /// Schedule this code block to run when build is complete
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (kDebugMode) {
          print('[QuestionWidget] Start Visual Help: ${current.toString()}');
        }

        /// Routes the user to the correct visual help page.
        /// depending on the arithmetic operation.
        switch (session.operand) {
          case '+':
            Navigator.push(context, AddRoute(session: session));
            break;
          case 'p':
            Navigator.push(context, AddyRoute(session: session));
            break;
          case '-':
            Navigator.push(context, SubRoute(session: session));
            break;
          case '*':
            Navigator.push(context, MulRoute(session: session));
            break;
          case 'm':
            Navigator.push(context, MulyRoute(session: session));
            break;
          case '/':
            Navigator.push(context, DivRoute(session: session));
            break;
          default:
            throw ArgumentError.value(
                session.operand, 'input', 'Invalid input');
        }
      });
    }

    // Check if the current question is of type "p" or "m"
    bool isPMQuestion =
        current.questionType == "p" || current.questionType == "m";

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayQuestion(current),
            style: const TextStyle(fontSize: 50),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SizedBox(
              width: 70,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      session.input.substring(0, min(session.input.length, 2)),
                      style: const TextStyle(fontSize: 40, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isPMQuestion)
            Text(
              displayQuestion(current, isFirstPart: false), //Second part
              style: const TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class PreviousQuestionWidget extends StatelessWidget {
  const PreviousQuestionWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PracticeSession session = Provider.of<PracticeSession>(context);

    // length - 1 is the current question, length - 2 is the previous question
    Question? previousQuestion = session.questions.length >= 2
        ? session.questions[session.questions.length - 2]
        : null;

    if (previousQuestion == null || previousQuestion.userAnswer == null) {
      return Container(height: 20, color: Colors.transparent);
    }
    // Check if the previous question is of type "p" or "m"
    bool isPMQuestion = previousQuestion.questionType == "p" ||
        previousQuestion.questionType == "m";

    // Get the previous question display parts
    String previousQuestionFirstPart =
        displayQuestion(previousQuestion, isFirstPart: true);
    String previousQuestionSecondPart =
        displayQuestion(previousQuestion, isFirstPart: false);

    // Combine with user answer and correct answer
    String previousQuestionWithUserAnswer;
    String previousQuestionWithCorrectAnswer;

    if (isPMQuestion == true) {
      previousQuestionWithUserAnswer =
          "$previousQuestionFirstPart ${previousQuestion.userAnswer}$previousQuestionSecondPart";
      previousQuestionWithCorrectAnswer =
          "$previousQuestionFirstPart ${previousQuestion.correctAnswer}$previousQuestionSecondPart";
    } else {
      previousQuestionWithUserAnswer =
          "$previousQuestionFirstPart ${previousQuestion.userAnswer}";
      previousQuestionWithCorrectAnswer =
          "$previousQuestionFirstPart ${previousQuestion.correctAnswer}";
    }

    return Column(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: previousQuestion.correct == true
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Text(
          previousQuestion.correct == true
              ? previousQuestionWithUserAnswer
              : previousQuestionWithUserAnswer.replaceFirst("=", "≠"),
          style: const TextStyle(fontSize: 20),
        ),
      ),
      const SizedBox(height: 10),
      if (previousQuestion.correct == false)
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1800),
          builder: (context, scale, child) {
            double scaleFactor;

            if (scale < 0.5) {
              scaleFactor = scale * (1.4 / 0.5);
            } else {
              scaleFactor = 1.4 - (scale - 0.5) * (1.4 / 0.5);
              scaleFactor = scaleFactor.clamp(1.0, double.infinity);
            }

            return Transform.scale(
              scale: scaleFactor,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green.withOpacity(0.3),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(previousQuestionWithCorrectAnswer,
                    style: const TextStyle(fontSize: 20)),
              ),
            );
          },
        ),
    ]);
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nativelib/nativelib.dart';
import 'package:olle_app/models/addition_strategy.dart';

/// Represents a single question in the session.
class Question {
  /// The first known number in the question, in left-to-right reading order.
  ///
  /// For example:
  /// * If the question is "2+4=?", then [firstNumber] is 2.
  /// * If the question is "3+?=7", then [firstNumber] is 3.
  final int firstNumber;

  /// The second known number in the question, in left-to-right reading order.
  ///
  /// For example:
  /// * If the question is "2+4=?", then [secondNumber] is 4.
  /// * If the question is "3+?=7", then [secondNumber] is 7.
  final int secondNumber;

  /// The question type, represented as a single char (see optQuestions.h).
  ///
  /// NOTE: The [questionType] is not necessarily the same thing as the mathematical
  /// operator. For example, the 'p' [questionType] uses the '+' operator.
  final String questionType;

  /// A single-char flag from optQuestions.h which determines the type of visual help to show for this question.
  ///
  /// * visualHelp == ' ' is the normal case, a regular question, where no visualization is shown.
  /// * visualHelp == 'a' means that a visualization should be shown by automatically pressing the "?" button for the user.
  /// * Any other value is reserved for future visualization types.
  final String visualHelp;

  /// The correct answer to the question.
  late final int correctAnswer;

  /// If the current question has been viewed or not
  /// only used and matters if [visualHelp] is 'a'
  bool viewed = false;

  /// The user's answer to the question, if given.
  ///
  /// An answer can only be given if [visualHelp] == ' ' because optQuestions.h
  /// does not allow answering visualHelp questions.
  String? userAnswer;

  /// Whether or not the user answered the question correctly.
  ///
  /// May be null if [userAnswer] is null, since the question is neither correct nor wrong
  /// if the user has not given an answer.
  bool? correct;

  /// The recommended strategy to use, if this is an addition question.
  AdditionStrategy? additionStrategy;

  Question(
      {required this.firstNumber,
      required this.secondNumber,
      required this.questionType,
      required this.visualHelp}) {
    // Validate single-char fields (as defined by optQuestions.h)
    assert(questionType.length == 1);
    assert(visualHelp.length == 1);

    if (questionType == '+') {
      additionStrategy = calcStrategy(firstNumber, secondNumber);
    }
  }

  /// Parses a [Question] from a string in the "X Y" format.
  ///
  /// The [xyString] should be in the format returned by optQ::getDataInputs(size_t) and related methods (the in-memory format).
  /// This format contains the so-called, by optQuestions.h, X and Y numbers (the two operands on the left hand side of the equation).
  /// The [xyString] may optionally contain a trailing visualHelp character, which will default to ' ' if omitted.
  /// See optQ::getDataInputs(size_t) in optQuestions.h for more details about the format.
  ///
  /// Examples:
  /// * `2+1`
  /// * `3p8` (represents `3+y=11` in the "known numbers" format)
  /// * `4m8` (represents `4*y=32` in the "known numbers" format)
  factory Question.fromXyString(String xyString) {
    /// question = "10-10 " or "10p10 "
    /// -> ["10", "10"]
    final List<String> parseNumbers = xyString.split(RegExp(r"[^\d]+"));

    /// question = "10-10 " or "10p10 "
    /// -> ["", "-", " "] or ["", "p", " "], respectively
    final List<String> parseFlags = xyString.split(RegExp(r"[\d]+"));

    /// Extract numbers from parsed list
    final int xNumber = int.parse(parseNumbers[0]);
    final int yNumber = int.parse(parseNumbers[1]);

    /// Parse Flags
    ///
    /// Note that visualHelp may be omitted due to the parsing workaround for
    /// the new getDataInputsStart format that has ambiguous spaces,
    /// so we need to handle that case and set a default visualHelp, " ".
    final String questionType = parseFlags[1];
    final String visualHelp = parseFlags[2].isNotEmpty ? parseFlags[2] : " ";

    return Question(
        firstNumber: xNumber,
        secondNumber: switch (questionType) {
          "p" => xNumber + yNumber,
          "m" => xNumber * yNumber,
          _ => yNumber
        },
        questionType: questionType,
        visualHelp: visualHelp);
  }

  /// Parses a [Question] from a string in the "known numbers" format.
  ///
  /// The [knownNumbersString] should be in the format returned by optQ::getQuestion (the file storage format).
  /// This format contains only the known numbers in the question and omits the number to solve for.
  /// The [knownNumbersString] may optionally contain a trailing visualHelp character, which will default to ' ' if omitted.
  /// See optQ::newQuestion and ::readQuestion in optQuestions.h for more details about the format.
  ///
  /// Examples:
  /// * `2+1`
  /// * `3+y=11` (represents `3p8` in the "X Y" format)
  /// * `4*y=32` (represents `4m8` in the "X Y" format)
  factory Question.fromKnownNumbersString(String knownNumbersString) {
    /// question = "10-10 " or "10+y=10 "
    /// -> ["10", "10"]
    final List<String> parseNumbers =
        knownNumbersString.split(RegExp(r"[^\d]+"));

    /// question = "10-10 " or "10+y=10 "
    /// -> ["", "-", " "] or ["", "+y=", " "], respectively
    final List<String> parseFlags = knownNumbersString.split(RegExp(r"[\d]+"));

    /// Extract numbers from parsed list
    final int firstNumber = int.parse(parseNumbers[0]);
    final int secondNumber = int.parse(parseNumbers[1]);

    /// Parse Flags
    ///
    /// Note that visualHelp may be omitted due to the parsing workaround for
    /// the new getDataInputsStart format that has ambiguous spaces,
    /// so we need to handle that case and set a default visualHelp, " ".
    final String middlePart = parseFlags[1];
    final String visualHelp = parseFlags[2].isNotEmpty ? parseFlags[2] : " ";

    return Question(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        questionType: switch (middlePart) {
          "+y=" => "p",
          "*y=" => "m",
          _ => middlePart
        },
        visualHelp: visualHelp);
  }

  @override
  String toString() {
    return 'Question: $firstNumber$questionType$secondNumber';
  }
}

/// Represents a practice session and its state.
///
/// Consists of a list of questions and a current input
/// [_input] is the current input, only used to display the input in the UI
/// [_questions] is the list of questions, used to keep track of the history
///
/// [operand] is the operator that all questions are based on.
/// Note that the operator in the questions can vary based on the users level.
/// '-' can be '+' and '/' can be '*'
/// [correctCounter] is amount of correct anwers in a session.
/// [wrongCounter] is amount of wrong anwers in a session.
/// [_ticker] notfier for UI elements, periodically calls [_onTick].
/// Initialized and disposed with PracticeSession.
class PracticeSession extends ChangeNotifier {
  final String operand;
  late Stopwatch _timer;
  late Timer _ticker;

  int _correctCounter = 0;
  int _wrongCounter = 0;
  int _hotStreak = 0;
  int _highestHotStreak = 0;

  int prevLevel = 0;
  int level = 0;
  Duration _statusTime = Duration.zero;
  String _correctString = "";

  int get correctCounter => _correctCounter;
  int get wrongCounter => _wrongCounter;
  int get hotStreak => _highestHotStreak;
  int get timer => _timer.elapsedMilliseconds;

  Duration get statusTime => _statusTime;
  String get correctString => _correctString;

  String _input = "";
  final List<Question> _questions = List.of([]);

  String get input => _input;
  List<Question> get questions => _questions;

  Question get question => _questions.last;

  PracticeSession({required this.operand}) {
    createQuestion(); // always start with a question
    initPrevLevel();
    updateLabels();
    _timer = Stopwatch();
    start();
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void start() {
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void startTimer() {
    _timer.start();
  }

  void stopTimer() {
    _timer.stop();
  }

  void resetTimer() {
    _timer.reset();
  }

  void _onTick(Timer timer) {
    //? Varför finns denna?
    //notifyListeners();
  }

  void initPrevLevel() async {
    prevLevel = await Nativelib.call("getLevel", [operand]);
  }

  void updateLabels() async {
    level = await Nativelib.call("getLevel", [operand]);
    double _tempStatusTime = await Nativelib.call("statusTime", [operand]);
    if (_tempStatusTime.isNaN || _tempStatusTime.isInfinite) {
      _tempStatusTime = 0;
    } else {
      _statusTime = Duration(milliseconds: (_tempStatusTime * 1000).toInt());
    }

    ///Original code from old project. Think it relies on the real AI model so might want to switch this back later.
    /*_statusTime = Duration(
        milliseconds:
            ((await Nativelib.call("statusTime", [operand])) * 1000).toInt());*/
    _correctString = await Nativelib.call("correctString", [operand]);
    notifyListeners();
  }

  /// sets [_input] to [value]
  set input(String value) {
    _input = value;
    notifyListeners();
  }

  /// appends a question to the list of questions
  set question(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  /// creates a new question using the native library
  /// [operand] is used to determine the operator of the question
  Future<void> createQuestion() async {
    await Nativelib.call("newQuestion", [operand]);
    final String questionStr = await Nativelib.call("getQuestion");
    question = Question.fromKnownNumbersString(questionStr);
    if (question.questionType == 'm' || question.questionType == 'p') {
      question.correctAnswer = await Nativelib.call("getY");
    } else {
      question.correctAnswer = await Nativelib.call("getZ");
    }

    if (kDebugMode) {
      print(
          '[CreateQuestion] new Question: ${question.toString()} | VH: ${question.visualHelp}');
    }

    startTimer();
  }

  /// answer the current question by calling the native library
  Future<void> _answer() async {
    question.userAnswer = input;
    input = '';

    // NOTE: This should only be called for non-visualHelp questions
    await Nativelib.call("determineAnswer"); // TODO check return string
    await Nativelib.call("saveAnswerToFile");
    question.correct =
        await Nativelib.call("getAnswer") == question.correctAnswer;

    incrementCorrectCounter(question.correct);

    await Nativelib.call("storeAnswer");

    updateLabels();
    await createQuestion();
    return;
  }

  /// Keeps track of amount of correct/wrong answers in a session
  void incrementCorrectCounter(bool? correct) {
    if (correct == null) {
    } else if (correct) {
      _hotStreak++;
      _correctCounter++;
    } else {
      _hotStreak = 0;
      _wrongCounter++;
    }

    if (_highestHotStreak < _hotStreak) {
      _highestHotStreak = _hotStreak;
    }
  }

  /// Adds a character to the input
  /// and executes certain actions based on the character
  ///
  /// [key] is the character that was pressed
  ///
  /// * '0'-'9' are appended to the input.
  /// * 'C' clears the input.
  /// * '<' removes the last character from the input.
  /// * '=' enters the answer and clears the input.
  /// This is a terminal action, a new question will be generated afterwards.
  /// * '?' shows a visualization for the question.
  /// * 'R' returns from a visualization.
  /// This is a terminal action, a new question will be generated afterwards.
  Future<void> addInput(String key) {
    return Nativelib.mutexPool.withResource(() => _addInputUnsafe(key));
  }

  /// Unsafe version of addInput, in that it has critical sections regarding
  /// the Nativelib calls (so concurrent _addInputUnsafe calls are unsafe).
  Future<void> _addInputUnsafe(String key) async {
    if (kDebugMode) {
      print('[PracticeSession - AddInput] $key');
    }
    await Nativelib.call("addKey", [key]);
    startTimer();
    if (num.tryParse(key) != null &&
        0 <= num.tryParse(key)! &&
        num.tryParse(key)! <= 9) {
      // if key string kan be interpreted as a digit
      // in the range 0-9
      input = _input + key;
    } else if (key == 'C') {
      input = "";
    } else if (key == '=') {
      await _answer();
    } else if (key == '<') {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    } else {
      throw ArgumentError.value(key, 'input', 'Invalid input');
    }

    notifyListeners();
  }
}

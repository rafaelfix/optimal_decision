import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/functions/practice_session.dart';

void main() {
  test("Question parsing test, known numbers format", () {
    final q1 = Question.fromKnownNumbersString("3+6");
    expect(q1.questionType, equals("+"));
    expect(q1.visualHelp, equals(" "));
    expect(q1.firstNumber, equals(3));
    expect(q1.secondNumber, equals(6));

    final q2 = Question.fromKnownNumbersString("3+6 ");
    expect(q2.questionType, equals("+"));
    expect(q2.visualHelp, equals(" "));
    expect(q2.firstNumber, equals(3));
    expect(q2.secondNumber, equals(6));

    final q3 = Question.fromKnownNumbersString("3+6a");
    expect(q3.questionType, equals("+"));
    expect(q3.visualHelp, equals("a"));
    expect(q3.firstNumber, equals(3));
    expect(q3.secondNumber, equals(6));

    final q4 = Question.fromKnownNumbersString("2+y=7 ");
    expect(q4.questionType, equals("p"));
    expect(q4.visualHelp, equals(" "));
    expect(q4.firstNumber, equals(2));
    expect(q4.secondNumber, equals(7));

    final q5 = Question.fromKnownNumbersString("8-3 ");
    expect(q5.questionType, equals("-"));
    expect(q5.visualHelp, equals(" "));
    expect(q5.firstNumber, equals(8));
    expect(q5.secondNumber, equals(3));

    final q6 = Question.fromKnownNumbersString("2*7 ");
    expect(q6.questionType, equals("*"));
    expect(q6.visualHelp, equals(" "));
    expect(q6.firstNumber, equals(2));
    expect(q6.secondNumber, equals(7));

    final q7 = Question.fromKnownNumbersString("4*y=20 ");
    expect(q7.questionType, equals("m"));
    expect(q7.visualHelp, equals(" "));
    expect(q7.firstNumber, equals(4));
    expect(q7.secondNumber, equals(20));

    final q8 = Question.fromKnownNumbersString("4*y=20a");
    expect(q8.questionType, equals("m"));
    expect(q8.visualHelp, equals("a"));
    expect(q8.firstNumber, equals(4));
    expect(q8.secondNumber, equals(20));

    final q9 = Question.fromKnownNumbersString("8/2 ");
    expect(q9.questionType, equals("/"));
    expect(q9.visualHelp, equals(" "));
    expect(q9.firstNumber, equals(8));
    expect(q9.secondNumber, equals(2));
  });

  test("Question parsing test, X Y numbers format", () {
    final q1 = Question.fromXyString("3+6");
    expect(q1.questionType, equals("+"));
    expect(q1.visualHelp, equals(" "));
    expect(q1.firstNumber, equals(3));
    expect(q1.secondNumber, equals(6));

    final q2 = Question.fromXyString("3+6 ");
    expect(q2.questionType, equals("+"));
    expect(q2.visualHelp, equals(" "));
    expect(q2.firstNumber, equals(3));
    expect(q2.secondNumber, equals(6));

    final q3 = Question.fromXyString("3+6a");
    expect(q3.questionType, equals("+"));
    expect(q3.visualHelp, equals("a"));
    expect(q3.firstNumber, equals(3));
    expect(q3.secondNumber, equals(6));

    final q4 = Question.fromXyString("2p5 ");
    expect(q4.questionType, equals("p"));
    expect(q4.visualHelp, equals(" "));
    expect(q4.firstNumber, equals(2));
    expect(q4.secondNumber, equals(7));

    final q5 = Question.fromXyString("8-3 ");
    expect(q5.questionType, equals("-"));
    expect(q5.visualHelp, equals(" "));
    expect(q5.firstNumber, equals(8));
    expect(q5.secondNumber, equals(3));

    final q6 = Question.fromXyString("2*7 ");
    expect(q6.questionType, equals("*"));
    expect(q6.visualHelp, equals(" "));
    expect(q6.firstNumber, equals(2));
    expect(q6.secondNumber, equals(7));

    final q7 = Question.fromXyString("4m5 ");
    expect(q7.questionType, equals("m"));
    expect(q7.visualHelp, equals(" "));
    expect(q7.firstNumber, equals(4));
    expect(q7.secondNumber, equals(20));

    final q8 = Question.fromXyString("4m5a");
    expect(q8.questionType, equals("m"));
    expect(q8.visualHelp, equals("a"));
    expect(q8.firstNumber, equals(4));
    expect(q8.secondNumber, equals(20));

    final q9 = Question.fromXyString("8/2 ");
    expect(q9.questionType, equals("/"));
    expect(q9.visualHelp, equals(" "));
    expect(q9.firstNumber, equals(8));
    expect(q9.secondNumber, equals(2));
  });
}

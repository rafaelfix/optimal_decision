import 'package:olle_app/functions/practice_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/models/addition_strategy.dart';

void main() {
  group("Test that correct Addition strategy is set to a question", () {
    test("Test question strategy dubblar", () {
      final Question question = Question(
          firstNumber: 2, secondNumber: 2, questionType: "+", visualHelp: " ");

      expect(question.additionStrategy, AdditionStrategy.dubblar);
    });
    test("Test question strategy nästan dubblar 1", () {
      final Question question = Question(
          firstNumber: 1, secondNumber: 2, questionType: "+", visualHelp: " ");

      expect(question.additionStrategy, AdditionStrategy.nastanDubblar1);
    });

    test("Test question strategy nästan dubblar 2", () {
      final Question question = Question(
          firstNumber: 1, secondNumber: 3, questionType: "+", visualHelp: " ");

      expect(question.additionStrategy, AdditionStrategy.nastanDubblar2);
    });

    test("Test question strategy räkna upp", () {
      final Question question = Question(
          firstNumber: 2, secondNumber: 6, questionType: "+", visualHelp: " ");

      expect(question.additionStrategy, AdditionStrategy.raknaUpp);
    });

    test("Test question strategy tiokompisar", () {
      final Question question = Question(
          firstNumber: 7, secondNumber: 4, questionType: "+", visualHelp: " ");

      expect(question.additionStrategy, AdditionStrategy.tiokompisar);
    });
  });
}

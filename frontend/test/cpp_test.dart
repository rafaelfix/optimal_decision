import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/functions/practice_session.dart';
import 'package:flutter/services.dart';
import 'mock_nativelib.dart';

void main() async {
  MockNativelib mockNativelib = MockNativelib();

  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('nativelib');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return mockNativelib.call(methodCall.method, methodCall.arguments);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('+ question creation', () async {
    PracticeSession session = PracticeSession(operand: '+');
    await session.createQuestion();
    expect(session.operand, '+');
    expect(session.questions.isNotEmpty, true);
    expect(session.questions[0].questionType, '+');
  });

  test('- question creation', () async {
    PracticeSession session = PracticeSession(operand: '-');
    await session.createQuestion();
    expect(session.operand, '-');
    expect(session.questions.isNotEmpty, true);
    expect(session.questions[0].questionType, '-');
  });

  test('* question creation', () async {
    PracticeSession session = PracticeSession(operand: '*');
    await session.createQuestion();
    expect(session.operand, '*');
    expect(session.questions.isNotEmpty, true);
    expect(session.questions[0].questionType, '*');
  });

  test('/ question creation', () async {
    PracticeSession session = PracticeSession(operand: '/');
    await session.createQuestion();
    expect(session.operand, '/');
    expect(session.questions.isNotEmpty, true);
    expect(session.questions[0].questionType, '/');
  });

  test('Input and streak test', () async {
    PracticeSession session = PracticeSession(operand: '+');
    await session.createQuestion();
    await session.addInput('1');
    await session.addInput('0');
    await session.addInput('=');
    expect(session.hotStreak, 1);
  });
}

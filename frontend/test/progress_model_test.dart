import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/functions/practice_session.dart';
import 'package:olle_app/functions/progress.dart';
import 'mock_nativelib.dart';

void main() {
  group("tests for ProgressModel class", () {
    late ProgressModel progressModel;
    late PracticeSession session;

    MockNativelib mockNativelib = MockNativelib();
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel = MethodChannel('nativelib');
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return mockNativelib.call(methodCall.method, methodCall.arguments);
      });
      progressModel = ProgressModel();
      session = PracticeSession(operand: '+');
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test("test resetProgress", () {
      // WidgetsFlutterBinding.ensureInitialized();
      session.incrementCorrectCounter(true);
      progressModel.setProgress(session: session);
      progressModel.resetProgress();
      expect(progressModel.progress, 0);
    });

    test("test increase progress", () {
      ProgressModel progressModel = ProgressModel();
      PracticeSession session = PracticeSession(operand: '+');
      session.incrementCorrectCounter(true);
      progressModel.setProgress(session: session);
      expect(progressModel.progress, greaterThan(0));
    });
  });
}

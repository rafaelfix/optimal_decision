// Denna kod måste köras innan alla test om det är beroende av c++ koden o körs på windows/linux
/*
import 'package:olle_app/test/mockNativelib.dart';
...

//Denna kod ska in i main
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
*/

class MockNativelib {
  String testQuestion = "";
  int testZ = -1;
  String testInput = "";
  Future<dynamic> call(String method, [dynamic args]) async {
    switch (method) {
      case 'newQuestion':
        if (args.length != 1) {
          return null;
        }
        switch (args[0]) {
          case '+':
            testQuestion = "5+5";
            testZ = 10;
            return null;
          case '-':
            testQuestion = "8-5";
            testZ = 3;
            return null;
          case '*':
            testQuestion = "1*5";
            testZ = 5;
            return null;
          case '/':
            testQuestion = "8/2";
            testZ = 4;
            return null;
        }
        return null;

      case 'getQuestion':
        return testQuestion;

      case 'getZ':
        return testZ;

      case 'correctString':
        return "correctString";

      case 'getAnswer':
        return int.parse(testInput);

      case 'getLevel':
        return 4;

      case 'statusTime':
        return 0.0;

      case 'addKey':
        if (args[0] == '=' || args[0] == 'C') {
          return;
        }
        testInput = testInput + args[0];
        return;

      default:
        return;
    }
  }
}

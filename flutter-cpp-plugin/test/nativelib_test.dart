import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nativelib/nativelib.dart';

void main() {
  const MethodChannel channel = MethodChannel('nativelib');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await Nativelib.call("yep"), '42');
  });
}

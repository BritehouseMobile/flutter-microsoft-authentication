import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_microsoft_authentication');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await FlutterMicrosoftAuthentication.platformVersion, '42');
  // });
}
